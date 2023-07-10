# SPDX-FileCopyrightText: Copyright (c) 2022 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

data "aws_availability_zones" "available" {}
data "aws_region" "current" {}

data "aws_ami" "lookup" {
  most_recent = true
  owners      = local.ami_lookup.owners
  dynamic "filter" {
    for_each = local.ami_lookup.filters
    content {
      name   = filter.value["name"]
      values = filter.value["values"]
    }
  }
}

data "aws_instances" "nodes" {
  filter {
    name   = "tag:aws:autoscaling:groupName"
    values = module.eks.eks_managed_node_groups["gpu_node_pool"]["node_group_autoscaling_group_names"]
  }
  instance_state_names = ["running"]
}

data "external" "setup_kube_config" {
  program = ["bash", "${path.module}/setup-kube-config.sh"]
  query = {
    aws_profile      = var.aws_profile
    aws_region       = data.aws_region.current.name
    eks_cluster_name = module.eks.cluster_id
    eks_cluster_arn  = module.eks.cluster_arn
  }
}

data "aws_eks_cluster" "holoscan" {
  name = module.eks.cluster_id
}
