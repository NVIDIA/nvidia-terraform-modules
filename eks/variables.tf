# SPDX-FileCopyrightText: Copyright (c) 2022-2024 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

/************************
  AWS Variables
*************************/

variable "aws_profile" {
  type        = string
  default     = "development"
  description = ""
}

variable "region" {
  default     = "us-west-2"
  description = "AWS region to provision the Kubernetes Cluster"
}


variable "cluster_name" {
  type = string
}

variable "cluster_version" {
  type        = string
  default     = "1.30"
  description = "Version of EKS to install on the control plane (Major and Minor version only, do not include the patch)"
}
/************************
  GPU Operator Variables
*************************/
variable "install_gpu_operator" {
  default     = "true"
  description = "Whether to Install GPU Operator. Defaults to false available."
}

variable "gpu_operator_version" {
  default     = "v24.9.0"
  description = "Version of the GPU Operator to deploy. Defaults to latest available. "
}

variable "gpu_operator_driver_version" {
  type        = string
  default     = "550.127.05"
  description = "The NVIDIA Driver version deployed with GPU Operator. Defaults to latest available."
}

variable "gpu_operator_namespace" {
  type        = string
  default     = "gpu-operator"
  description = "The namespace for the GPU operator deployment"
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

/*****************************
  Managed Node Pool Variables
******************************/

/******************************
  GPU-only  Node Pool Variables
*******************************/
variable "gpu_ami_id" {
  type        = string
  description = "AMI ID of the EKS Ubuntu Image cooresponding to the region and version of the cluser. Not required as we do a lookup for this image"
  default     = ""
}

variable "gpu_instance_type" {
  type        = string
  default     = "g6e.12xlarge"
  description = "GPU EC2 worker node instance type"
}

variable "max_gpu_nodes" {
  type        = string
  default     = "5"
  description = "Maximum number of GPU nodes in the Autoscaling Group"
}

variable "min_gpu_nodes" {
  type        = string
  default     = "2"
  description = "Minimum number of GPU nodes in the Autoscaling Group"
}

variable "desired_count_gpu_nodes" {
  type        = string
  default     = "2"
  description = "Minimum number of GPU nodes in the Autoscaling Group"
}

variable "gpu_node_pool_root_disk_size_gb" {
  type        = number
  default     = 512
  description = "The size of the root disk on all GPU nodes in the EKS-managed GPU-only Node Pool. This is primarily for container image storage on the node"
}

variable "gpu_node_pool_root_volume_type" {
  type        = string
  default     = "gp2"
  description = "The type of disk to use for the GPU node pool root disk (eg. gp2, gp3). Note, this is different from the type of disk used by applications via EKS Storage classes/PVs & PVCs"
}

variable "gpu_node_pool_delete_on_termination" {
  type        = bool
  default     = true
  description = "Delete the VM nodes root filesystem on each node of the instance type. This is set to true by default, but can be changed when desired when using the 'local-storage provisioner' and are keeping important application data on the nodes"
}

variable "gpu_node_pool_additional_user_data" {
  type        = string
  default     = ""
  description = "User data that is appended to the user data script after of the EKS bootstrap script on EKS-managed GPU node pool."
}

/************************
  CPU-only  Node Pool Variables
*************************/

variable "cpu_instance_type" {
  type        = string
  default     = "t2.xlarge"
  description = "CPU EC2 worker node instance type"
}

variable "cpu_node_pool_root_disk_size_gb" {
  type        = number
  default     = 512
  description = "The size of the root disk on all GPU nodes in the EKS-managed GPU-only Node Pool. This is primarily for container image storage on the node"
}

variable "cpu_node_pool_root_volume_type" {
  type        = string
  default     = "gp2"
  description = "The type of disk to use for the GPU node pool root disk (eg. gp2, gp3). Note, this is different from the type of disk used by applications via EKS Storage classes/PVs & PVCs"
}

variable "cpu_node_pool_delete_on_termination" {
  type        = bool
  default     = true
  description = "Delete the VM nodes root filesystem on each node of the instance type. This is set to true by default, but can be changed when desired when using the 'local-storage provisioner' and are keeping important application data on the nodes"
}

variable "cpu_node_pool_additional_user_data" {
  type        = string
  default     = ""
  description = "User data that is appended to the user data script after of the EKS bootstrap script on EKS-managed GPU node pool."
}

variable "max_cpu_nodes" {
  type        = string
  default     = "2"
  description = "Maximum number of CPU nodes in the Autoscaling Group"
}

variable "min_cpu_nodes" {
  type        = string
  default     = "0"
  description = "Minimum number of CPU nodes in the Autoscaling Group"
}

variable "desired_count_cpu_nodes" {
  type        = string
  default     = "1"
  description = "Minimum number of CPU nodes in the Autoscaling Group"
}


variable "existing_vpc_details" {
  type = object({
    vpc_id     = string
    subnet_ids = list(string)
  })
  default     = null
  description = "Variables used for re-using existing VPC for vpc_id & subnet_id"
}

variable "cidr_block" {
  type        = string
  default     = "10.0.0.0/16"
  description = "CIDR for VPC"
}

variable "additional_user_data" {
  type        = string
  default     = ""
  description = "User data that is appended to the user data script after of the EKS bootstrap script."
}

variable "private_subnets" {
  type        = list(any)
  description = "List of subnet ranges for the Private VPC"
  default     = ["10.0.0.0/19", "10.0.32.0/19", "10.0.64.0/19"]
}

variable "public_subnets" {
  type        = list(any)
  description = "List of subnet ranges for the Private VPC"
  default     = ["10.0.96.0/19", "10.0.128.0/19", "10.0.160.0/19"]
}

variable "ssh_key" {
  type    = string
  default = ""
}

variable "enable_nat_gateway" {
  description = "Should be true if you want to provision NAT Gateways for each of your private networks"
  default     = true
  type        = bool
}

variable "single_nat_gateway" {
  type        = bool
  description = "Should be true if you want to provision a single shared NAT Gateway across all of your private networks"
  default     = false
}

variable "enable_dns_support" {
  type        = bool
  default     = true
  description = "Whether or not the Default VPC has DNS support"
}

variable "enable_dns_hostnames" {
  description = "Whether or not the Default VPC has DNS hostname support"
  default     = true
  type        = bool
}

variable "additional_security_group_ids" {
  type        = list(any)
  default     = []
  description = "list of additional security groups to add to nodes"
}

variable "additional_node_security_groups_rules" {
  description = "List of additional security group rules to add to the node security group created"
  type        = any
  default     = {}
}