# SPDX-FileCopyrightText: Copyright (c) 2022-2023 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

/***************************
VPC Network Configuration
***************************/
resource "google_compute_network" "holoscan-vpc" {
  name                    = "${var.cluster_name}-vpc"
  auto_create_subnetworks = "false"
}

/***************************
Subnet Configuration
***************************/
resource "google_compute_subnetwork" "holoscan-subnet" {
  name          = "${var.cluster_name}-subnet"
  region        = var.region
  network       = google_compute_network.holoscan-vpc.name
  ip_cidr_range = "10.150.0.0/24"
}

/***************************
GKE Configuration
***************************/

# Add data block to provide latest k8s version as an output
data "google_container_engine_versions" "latest" {
  provider = google-beta
  location = var.region
}

resource "google_container_cluster" "holoscan" {
  name     = var.cluster_name
  location = var.region
  release_channel {
    channel = var.release_channel
  }
  # Default Node Pool is required, to create a cluster, but we need a custom one instead
  # So we delete the default
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.holoscan-vpc.name
  subnetwork = google_compute_subnetwork.holoscan-subnet.name

  // Workload Identity Configuration
  workload_identity_config {
    workload_pool = "${data.google_project.cluster.project_id}.svc.id.goog"
  }
}
/***************************
GKE CPU Node Pool Config
***************************/
resource "google_container_node_pool" "cpu_nodes" {
  name       = "tf-${var.cluster_name}-cpu-pool"
  location   = var.region
  cluster    = google_container_cluster.holoscan.name
  node_count = var.num_cpu_nodes
  autoscaling {
    min_node_count = var.cpu_min_node_count
    max_node_count = var.cpu_max_node_count
  }
  node_locations = var.node_zones
  node_config {
    image_type = "UBUNTU_CONTAINERD"
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/compute"
    ]

    preemptible  = var.use_cpu_spot_instances
    machine_type = var.cpu_instance_type
    tags         = ["tf-managed", "${var.cluster_name}"]
    metadata = {
      disable-legacy-endpoints = "true"
    }

    labels = {
      part_of    = var.cluster_name
      env        = var.project_id
      managed_by = "terraform"
    }
    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }
  timeouts {
    create = "30m"
    update = "20m"
  }
}

/***************************
GKE GPU Node Pool Config
***************************/
resource "google_container_node_pool" "gpu_nodes" {
  name           = "tf-${var.cluster_name}-gpu-pool"
  location       = var.region
  cluster        = google_container_cluster.holoscan.name
  node_locations = var.node_zones
  node_count     = var.num_gpu_nodes
  autoscaling {
    min_node_count = var.gpu_min_node_count
    max_node_count = var.gpu_max_node_count
  }
  node_config {
    image_type = "UBUNTU_CONTAINERD"
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/compute"
    ]
    guest_accelerator {
      type  = var.gpu_type
      count = var.gpu_count
    }

    preemptible  = var.use_gpu_spot_instances
    machine_type = var.gpu_instance_type
    tags         = ["tf-managed", "${var.cluster_name}"]
    metadata = {
      disable-legacy-endpoints = "true"
    }

    labels = {
      part_of    = var.cluster_name
      env        = var.project_id
      managed_by = "terraform"
    }
    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }
  timeouts {
    create = "30m"
    update = "20m"
  }
}

/***************************
Create GPU Operator Namespace
***************************/
resource "kubernetes_namespace_v1" "gpu-operator" {
  metadata {
    annotations = {
      name = "gpu-operator"
    }

    labels = {
      cluster    = var.cluster_name
      managed_by = "Terraform"
    }

    name = var.gpu_operator_namespace
  }
}
/***************************
K8s Resource Quota Config
***************************/
resource "kubernetes_resource_quota_v1" "gpu-operator-quota" {
  depends_on = [google_container_node_pool.gpu_nodes, kubernetes_namespace_v1.gpu-operator]
  metadata {
    name      = "gpu-operator-quota"
    namespace = var.gpu_operator_namespace
  }
  spec {
    hard = {
      pods = 100
    }
    scope_selector {
      match_expression {
        operator   = "In"
        scope_name = "PriorityClass"
        values     = ["system-node-critical", "system-cluster-critical"]
      }
    }
  }
}
/***************************
GPU Operator Configuration
***************************/
resource "helm_release" "gpu-operator" {
  depends_on       = [google_container_node_pool.gpu_nodes, kubernetes_resource_quota_v1.gpu-operator-quota, kubernetes_namespace_v1.gpu-operator]
  name             = "gpu-operator"
  repository       = "https://helm.ngc.nvidia.com/nvidia"
  chart            = "gpu-operator"
  version          = var.gpu_operator_version
  namespace        = var.gpu_operator_namespace
  create_namespace = false
  atomic           = true
  cleanup_on_fail  = true
  reset_values     = true
  replace          = true

  set {
	name   = "driver.version"
        value  = var.gpu_operator_driver_version
  }

}

