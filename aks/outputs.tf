# SPDX-FileCopyrightText: Copyright (c) 2022-2023 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

output "resource_group_name" {
  value = var.existing_resource_group_name == null ? azurerm_resource_group.aks[0].name : data.azurerm_resource_group.existing[0].name
}

output "kubernetes_cluster_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

output "client_certificate" {
  sensitive = true
  value     = azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate
}

output "kube_config" {
  value     = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive = true
}

output "location" {
  value = azurerm_kubernetes_cluster.aks.location
}
