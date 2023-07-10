# SPDX-FileCopyrightText: Copyright (c) 2022-2023 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

/*******************************************
Holoscan Cluster Config
*******************************************/

locals {

  ingress_cluster_metrics_server_rule = var.metrics_server_enabled ? {
    ingress_cluster_metrics_server_rule = {
      description                   = "Cluster API to metrics server"
      protocol                      = "tcp"
      from_port                     = 4443
      to_port                       = 4443
      type                          = "ingress"
      source_cluster_security_group = true
  } } : {}

  ingress_cluster_prom_adapter_rule = var.prom_adapter_enabled ? {
    ingress_cluster_prom_adapter = {
      description                   = "Cluster API to prometheus adapter"
      protocol                      = "tcp"
      from_port                     = 6443
      to_port                       = 6443
      type                          = "ingress"
      source_cluster_security_group = true
  } } : {}



}

// Create Holoscan Cluster from the root module
module "holoscan-eks-cluster" {
  source                                = "../.."
  cluster_name                          = var.cluster_name
  additional_node_security_groups_rules = merge(local.ingress_cluster_metrics_server_rule, local.ingress_cluster_prom_adapter_rule)
}
