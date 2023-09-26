# SPDX-FileCopyrightText: Copyright (c) 2023 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
/*******************************************
Fluentbit Config
*******************************************/

// Create an Azure Log Analytics Workspace to send Fluentbit Logs to
resource "azurerm_log_analytics_workspace" "cnpack-fluentbit-workspace" {
  name                = var.fluentbit_workspace_name
  location            = module.holoscan-ready-aks.location
  resource_group_name = module.holoscan-ready-aks.resource_group_name
  sku                 = var.azure_log_analytics_sku
  retention_in_days   = var.azure_log_analytics_retention_in_days
}

data "azurerm_log_analytics_workspace" "fluent" {
  depends_on          = [azurerm_log_analytics_workspace.cnpack-fluentbit-workspace]
  name                = var.fluentbit_workspace_name
  resource_group_name = module.holoscan-ready-aks.resource_group_name
}

// Create the nvidia-monitoring namespace and the secret needed for CNPack fluentbit on AKS
resource "null_resource" "create-fluentbit-secret" {
  provisioner "local-exec" {
    command = "kubectl create namespace nvidia-monitoring"
  }

  provisioner "local-exec" {
    command = "kubectl create secret generic fluentbit-secrets -n nvidia-monitoring --from-literal=WorkspaceId=${data.azurerm_log_analytics_workspace.fluent.workspace_id}  --from-literal=SharedKey=${data.azurerm_log_analytics_workspace.fluent.primary_shared_key}"
  }
}

// Output the name of the created secret for use with CNPack
output "fluentbit-secret-name" {
  value = "fluentbit-secrets"
}

// Output the namespace of the created secret for use with CNPack
output "fluentbit-secret-namespace" {
  value = "nvidia-monitoring"
}