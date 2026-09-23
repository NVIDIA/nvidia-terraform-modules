# SPDX-FileCopyrightText: Copyright (c) 2022-2024 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0




/***************************
VPC Network Configuration
***************************/
resource "google_compute_network" "gke-vpc" {
  count                   = var.vpc_enabled ? 1 : 0
  name                    = "${var.cluster_name}-vpc"
  auto_create_subnetworks = "false"
  project                 = var.project_id
}

/***************************
Subnet Configuration
***************************/
resource "google_compute_subnetwork" "gke-subnet" {
  name          = "${var.cluster_name}-subnet"
  count         = var.vpc_enabled ? 1 : 0
  region        = var.region
  network       = google_compute_network.gke-vpc[0].name
  ip_cidr_range = "10.150.0.0/24"
  project       = var.project_id
}

/***************************
GKE Configuration
***************************/

# Add data block to provide latest k8s version as an output
data "google_container_engine_versions" "latest" {
  provider = google-beta
  location = var.region
  project  = var.project_id
}

resource "google_container_cluster" "gke" {
  name     = var.cluster_name
  project  = var.project_id
  location = length(var.node_zones) == 1 ? one(var.node_zones) : var.region
  release_channel {
    channel = var.release_channel
  }
  min_master_version = var.min_master_version
  # Default Node Pool is required, to create a cluster, but we need a custom one instead
  # So we delete the default
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = var.vpc_enabled ? google_compute_network.gke-vpc[0].name : var.network
  subnetwork = var.vpc_enabled ? google_compute_subnetwork.gke-subnet[0].name : var.subnetwork

  deletion_protection = true
  
  // Workload Identity Configuration
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
}
/***************************
GKE CPU Node Pool Config
***************************/


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
  count            = var.install_gpu_operator ? 1 : 0
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
    name  = "driver.version"
    value = var.gpu_operator_driver_version
  }

}

/***************************
Create NIM Operator Namespace
***************************/
resource "kubernetes_namespace_v1" "nim-operator" {
  metadata {
    annotations = {
      name = "nim-operator"
    }

    labels = {
      cluster    = var.cluster_name
      managed_by = "Terraform"
    }

    name = var.nim_operator_namespace
  }
}
/***************************
K8s Resource Quota Config
***************************/
resource "kubernetes_resource_quota_v1" "nim-operator-quota" {
  depends_on = [google_container_node_pool.gpu_nodes, kubernetes_namespace_v1.nim-operator]
  metadata {
    name      = "gpu-operator-quota"
    namespace = var.nim_operator_namespace
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

/********************************************
 NIM Operator Configuration
********************************************/
resource "helm_release" "nim_operator" {
  depends_on       = [google_container_node_pool.gpu_nodes, kubernetes_resource_quota_v1.nim-operator-quota, kubernetes_namespace_v1.nim-operator]
  count            = var.install_nim_operator ? 1 : 0
  name             = "nim-operator"
  repository       = "https://helm.ngc.nvidia.com/nvidia"
  chart            = "k8s-nim-operator"
  version          = var.nim_operator_version
  namespace        = var.nim_operator_namespace
  create_namespace = true
  atomic           = true
  cleanup_on_fail  = true
  reset_values     = true
  replace          = true
}
