# SPDX-FileCopyrightText: Copyright (c) 2022 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
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
  type        = list(any)
}

variable "release_channel" {
  default     = "REGULAR"
  description = "Configuration options for the Release channel feature, which provide more control over automatic upgrades of your GKE clusters. When updating this field, GKE imposes specific version requirements"
}

/***************************
GKE CPU Node Pool Variables
***************************/

variable "cpu_min_node_count" {
  default     = "1"
  description = "Number of CPU nodes in CPU nodepool"
}

variable "cpu_max_node_count" {
  default     = "5"
  description = "Max Number of CPU nodes in CPU nodepool"
}

variable "use_cpu_spot_instances" {
  default     = false
  description = "Use Spot instance for CPU pool"
}

variable "cpu_instance_type" {
  default     = "n1-standard-4"
  description = "Machine Type for CPU node pool"
}

variable "num_cpu_nodes" {
  default     = 1
  description = "Number of CPU nodes when pool is created"
}

/***************************
GKE GPU  Node Pool Variables
***************************/
variable "gpu_type" {
  default     = "nvidia-tesla-v100"
  description = "GPU SKU To attach to Holoscan GPU Node (eg. nvidia-tesla-k80)"
}
variable "gpu_min_node_count" {
  default     = "2"
  description = "Min number of GPU nodes in GPU nodepool"
}

variable "gpu_max_node_count" {
  default     = "5"
  description = "Max Number of GPU nodes in GPU nodepool"
}

variable "use_gpu_spot_instances" {
  default     = false
  description = "Use Spot instance for GPU pool"
}

variable "num_gpu_nodes" {
  default     = 2
  description = "Number of GPU nodes when pool is created"
}

variable "gpu_count" {
  default     = "1"
  description = "Number of GPUs to attach to each node in GPU pool"
}

variable "gpu_instance_type" {
  default     = "n1-standard-4"
  description = "Machine Type for GPU node pool"
}

/***************************
GPU Operator Variables
***************************/
variable "gpu_operator_version" {
  default     = "v23.3.2"
  description = "Version of the GPU operator to be installed"
}

variable "gpu_operator_driver_version" {
  type        = string
  default     = "535.54.03"
  description = "The NVIDIA Driver version of GPU Operator"
}

variable "gpu_operator_namespace" {
  default     = "gpu-operator"
  description = "The namespace to deploy the NVIDIA GPU operator intov"
}
