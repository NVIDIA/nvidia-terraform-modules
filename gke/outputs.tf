# SPDX-FileCopyrightText: Copyright (c) 2022 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

/***************************
Outputs
***************************/

output "region" {
  value       = var.region
  description = "Region for Holoscan Resources to be created in when using this module"
}

output "project_id" {
  value       = var.project_id
  description = "GCloud Project ID"
}

/***************************
VPC Network Outputs
***************************/

output "vpc_project" {
  value       = google_compute_network.holoscan-vpc[*].project
  description = "Project of the VPC network (can be different from the project launching Kubernetes resources)"
}

output "subnet_cidr_range" {
  value       = google_compute_subnetwork.holoscan-subnet[*].ip_cidr_range
  description = "The IPs and CIDRs of the subnets"
}

output "subnet_region" {
  value       = google_compute_subnetwork.holoscan-subnet[*].region
  description = "The region of the VPC subnet used in this module"
}
/***************************
GKE Outputs
***************************/
output "kubernetes_cluster_name" {
  value       = google_container_cluster.holoscan.name
  description = "Holoscan Ready GKE Cluster Name"
}

output "kubernetes_cluster_endpoint_ip" {
  value       = google_container_cluster.holoscan.endpoint
  description = "GKE Cluster IP Endpoint"
}

output "kubernetes_config_file" {
  value       = google_container_cluster.holoscan.master_auth.0.cluster_ca_certificate
  description = "GKE Cluster IP Endpoint"
  sensitive   = true
}

output "rapid_channel_latest_gke_version" {
  value       = data.google_container_engine_versions.latest.release_channel_latest_version["RAPID"]
  description = "The latest available version of GKE when using the RAPID channel"
}

output "stable_channel_latest_gke_version" {
  value       = data.google_container_engine_versions.latest.release_channel_latest_version["STABLE"]
  description = "The latest available version of GKE when using the STABLE channel"
}
