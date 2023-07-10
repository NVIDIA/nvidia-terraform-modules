# SPDX-FileCopyrightText: Copyright (c) 2023 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

/***************************
GCP Variables
***************************/

variable "project_id" {
  description = "GCP Project ID for the VPC and K8s Cluster. This module currently does not support projects with a SharedVPC"
}

variable "region" {
  description = "The Region resources (VPC, GKE, Compute Nodes) will be created in"
}

/***************************
GKE Variables
***************************/
variable "cluster_name" {
  description = "Name of the Kubernetes Cluster to provision"
  type        = string
}

variable "node_zones" {
  description = "Specify zones to put nodes in (must be in same region defined above)"
  type        = list(string)
}

/*******************************************
GCP Managed Prometheus Variables
*******************************************/
variable "gke_managed_prometheus_enabled" {
  type        = bool
  default     = true
  description = "Set to true to enable, false to disable"
}


