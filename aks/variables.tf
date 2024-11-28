# SPDX-FileCopyrightText: Copyright (c) 2022-2024 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

/****************************
Azure Resource Group Variables
****************************/

variable "existing_resource_group_name" {
  description = "The name of an existing resource group the Kubernetes cluster should be deployed into. Defaults to the name of the cluster + `-rg` if none is specified"
  default     = null
  type        = string
}

variable "location" {
  description = "The region to create resources in"
}

/****************************
AKS Variables
****************************/

variable "cluster_name" {
  default     = "aks-cluster"
  description = "The name of the AKS Cluster to be created"
}

variable "kubernetes_version" {
  default     = "1.30"
  description = "Version of Kubernetes to turn on. Run 'az aks get-versions --location <location> --output table' to view all available versions "
}

variable "cpu_node_pool_disk_size" {
  description = "Disk size in GB of nodes in the Default GPU pool"
  default     = 100
}

variable "cpu_node_pool_count" {
  description = "Count of nodes in Default GPU pool"
  default     = 1
}

variable "cpu_node_pool_min_count" {
  description = "Min ount of number of nodes in Default CPU pool"
  default     = 1
}
variable "cpu_node_pool_max_count" {
  description = "Max count of nodes in Default CPU pool"
  default     = 5
}
variable "cpu_machine_type" {
  default     = "Standard_D16_v5"
  description = "Machine instance type of the AKS CPU node pool"
}
variable "cpu_os_sku" {
  description = "Specifies the OS SKU used by the agent pool. Possible values include: Ubuntu, CBLMariner, Mariner, Windows2019, Windows2022"
  default     = "Ubuntu"
}

/****************************
GPU Node Pool Variables
****************************/
variable "gpu_node_pool_disk_size" {
  description = "Disk size in GB of nodes in the Default GPU pool"
  default     = 100
}
variable "gpu_node_pool_count" {
  description = "Count of nodes in Default GPU pool"
  default     = 2
}
variable "gpu_node_pool_min_count" {
  description = "Min count of number of nodes in Default GPU pool"
  default     = 2
}
variable "gpu_node_pool_max_count" {
  description = "Max count of nodes in Default GPU pool"
  default     = 5
}
variable "gpu_machine_type" {
  default     = "Standard_NC6s_v3"
  description = "Machine instance type of the AKS GPU node pool"
}
variable "gpu_os_sku" {
  description = "Specifies the OS SKU used by the agent pool. Possible values include: Ubuntu, CBLMariner, Mariner, Windows2019, Windows2022"
  default     = "Ubuntu"
}
/****************************
GPU Operator Variables
****************************/
variable "install_gpu_operator" {
  default     = "true"
  description = "Whether to Install GPU Operator. Defaults to false available."
}

variable "gpu_operator_version" {
  default     = "v24.9.0"
  description = "Version of the GPU operator to be installed"
}

variable "gpu_operator_namespace" {
  type        = string
  default     = "gpu-operator"
  description = "The namespace to deploy the NVIDIA GPU operator into"
}

variable "gpu_operator_driver_version" {
  type        = string
  default     = "550.127.05"
  description = "The NVIDIA Driver version deployed with GPU Operator. Defaults to latest available."
}

/************************
  NIM Operator Variables
*************************/
variable "install_nim_operator" {
  default     = "false"
  description = "Whether to Install NIM Operator. Defaults to false available."
}

variable "nim_operator_version" {
  default     = "v1.0.0"
  description = "Version of the GPU Operator to deploy. Defaults to latest available."
}

variable "nim_operator_namespace" {
  type        = string
  default     = "nim-operator"
  description = "The namespace for the GPU operator deployment"
}

/****************************
Active Directory Variables
****************************/
variable "admin_group_object_ids" {
  type        = list(any)
  description = <<EOH
  (Required) A list of Object IDs (GUIDs) of Azure Active Directory Groups which should have Owner Role on the Cluster. 
  This is not the email address of the group, the GUID can be found in the Azure panel by searching for the AD Group
  NOTE: You will need Azure "Owner" role (not "Contributor") to attach an AD role to the Kubernetes cluster.
  EOH
}
