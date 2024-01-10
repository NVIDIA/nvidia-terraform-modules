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

variable "vpc_enabled" {
  default     = true
  type        = bool
  description = "Variable to control nvidia-kubernetes GKE module VPC creation"
}

variable "network" {
  default     = ""
  type        = string
  description = "Network CIDR for VPC"
}

variable "subnetwork" {
  type        = string
  default     = ""
  description = "Subnet name used for k8s cluster nodes"
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

variable "gpu_instance_tags" {
  type        = list(string)
  default     = []
  description = "GPU instance nodes tags"
}
variable "disk_size_gb" {
  default = "512"
  type    = string
}

/***************************
GPU Operator Variables
***************************/
variable "gpu_operator_version" {
  default     = "v23.6.1"
  description = "Version of the GPU Operator to deploy. Defaults to latest available. Not set when `nvaie` is set to `true`"
}

variable "gpu_operator_driver_version" {
  type        = string
  default     = "535.104.05"
  description = "The NVIDIA Driver version deployed with GPU Operator. Defaults to latest available. Not set when `nvaie` is set to true"
}

variable "gpu_operator_namespace" {
  type        = string
  default     = "gpu-operator"
  description = "The namespace to deploy the NVIDIA GPU operator into"
}

variable "nvaie" {
  type        = bool
  default     = false
  description = "To use the versions of GPU operator and drivers specified as part of NVIDIA AI Enterprise, set this to true. More information at https://www.nvidia.com/en-us/data-center/products/ai-enterprise"
}

variable "nvaie_gpu_operator_version" {
  type        = string
  default     = "v23.3.2"
  description = "The NVIDIA Driver version of GPU Operator. Overrides `gpu_operator_version` when `nvaie` is set to `true`"
}

variable "nvaie_gpu_operator_driver_version" {
  type        = string
  default     = "525.125.06"
  description = "The NVIDIA AI Enterprise version of the NVIDIA driver to be installed with the GPU operator. Overrides `gpu_operator_driver_version` when `nvaie` is set to `true`"
}
