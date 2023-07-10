# SPDX-FileCopyrightText: Copyright (c) 2022 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

/****************************
Azure Variables
****************************/

variable "location" {
  description = "The region to create resources in"
}

/****************************
AKS Variables
****************************/

variable "cluster_name" {
  default     = "holoscan-cluster"
  description = "The name of the AKS Cluster to be created"
}

variable "kubernetes_version" {
  default     = "1.26.3"
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
variable "gpu_operator_version" {
  default     = "v23.3.2"
  description = "Version of the GPU operator to be installed"
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