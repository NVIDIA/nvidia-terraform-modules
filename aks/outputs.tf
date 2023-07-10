# SPDX-FileCopyrightText: Copyright (c) 2022 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

output "resource_group_name" {
  value = azurerm_resource_group.holoscan.name
}

output "kubernetes_cluster_name" {
  value = azurerm_kubernetes_cluster.holoscan.name
}

output "client_certificate" {
  sensitive = true
  value     = azurerm_kubernetes_cluster.holoscan.kube_config.0.client_certificate
}

output "kube_config" {
  value     = azurerm_kubernetes_cluster.holoscan.kube_config_raw
  sensitive = true
}

output "location" {
  value = azurerm_kubernetes_cluster.holoscan.location
}