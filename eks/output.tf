# SPDX-FileCopyrightText: Copyright (c) 2022-2023 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

output "private_subnet_ids" {
  value = module.vpc.*.private_subnets
}

output "public_subnet_ids" {
  value = module.vpc.*.public_subnets
}

output "nodes" {
  value = data.aws_instances.nodes.public_ips
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cpu_node_role_name" {
  description = "IAM Node Role Bane for CPU node pools"
  value       = module.eks.eks_managed_node_groups.cpu_node_pool.iam_role_name
}

output "gpu_node_role_name" {
  description = "IAM Node Role Name for GPU node pools"
  value       = module.eks.eks_managed_node_groups.gpu_node_pool.iam_role_name
}

output "oidc_endpoint" {
  value = module.eks.oidc_provider
}
output "cluster_ca_certificate" {
  value     = module.eks.cluster_certificate_authority_data
  sensitive = true
}

output "kube_exec_api_version" {
  value = "client.authentication.k8s.io/v1beta1"
}

output "kube_exec_command" {
  value = "aws"
}

output "kube_exec_args" {
  value = [
    # "--profile",
    # var.aws_profile,
    "eks",
    "get-token",
    "--region",
    data.aws_region.current.name,
    "--cluster-name",
    module.eks.cluster_id
  ]
}
