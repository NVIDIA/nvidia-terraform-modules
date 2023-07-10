# SPDX-FileCopyrightText: Copyright (c) 2023 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

// This module does the following
# 1. Create user-assigned managed identity
# 2. Create azure_monitor_workspace (basic)
# 3. Attach monitoring metrics publishing role to user-assigned managed identity for use in CNPack
# 4. Grant user-assigned managed identity to VMSS (x2)
# 5. Output ingest URL as TF output & client id of user-assigned managed identity for use in CNPack

/*******************************************
Prometheus  Configuration
*********************************************/

// Fetch information about the Cluster Managed Identity
data "azurerm_user_assigned_identity" "cnpack-cluster-managed-id" {
  depends_on          = [module.holoscan-ready-aks]
  name                = "${module.holoscan-ready-aks.kubernetes_cluster_name}-agentpool"
  resource_group_name = "MC_${module.holoscan-ready-aks.resource_group_name}_${module.holoscan-ready-aks.kubernetes_cluster_name}_${module.holoscan-ready-aks.location}"
}
// Output info on managed ID for use with CNPack
output "cluster_managed-client-id" {
  value = data.azurerm_user_assigned_identity.cnpack-cluster-managed-id.client_id
}
// Get data Resource Group for Prometheus
data "azurerm_resource_group" "prometheus" {
  depends_on = [module.holoscan-ready-aks]
  name       = "MC_${module.holoscan-ready-aks.resource_group_name}_${module.holoscan-ready-aks.kubernetes_cluster_name}_${module.holoscan-ready-aks.location}"
}

// Create Azure Monitor Workspace for Prometheus
resource "azapi_resource" "prometheus-cnpack" {
  depends_on                = [module.holoscan-ready-aks]
  type                      = "microsoft.monitor/accounts@2023-04-03"
  name                      = var.prometheus-name
  schema_validation_enabled = false
  parent_id                 = data.azurerm_resource_group.prometheus.id
  location                  = data.azurerm_resource_group.prometheus.location

  response_export_values = ["*"]
}

// Get Data on Azure Monitor Workspace for Prometheus
data "azapi_resource" "prometheus-cnpack" {
  depends_on             = [module.holoscan-ready-aks, azapi_resource.prometheus-cnpack]
  name                   = var.prometheus-name
  type                   = "microsoft.monitor/accounts@2023-04-03"
  parent_id              = data.azurerm_resource_group.prometheus.id
  response_export_values = ["*"]
}

// Output the Ingestion URL of Prometheus for use with CNPack
output "prometheus-query-url" {
  value = jsondecode(data.azapi_resource.prometheus-cnpack.output).properties.metrics.prometheusQueryEndpoint
}

// Attach User Managed Identity to Monitoring Metrics Publisher role
resource "azurerm_role_assignment" "cnpack-prometheus-role" {
  scope                = jsondecode(data.azapi_resource.prometheus-cnpack.output).properties.defaultIngestionSettings.dataCollectionRuleResourceId
  role_definition_name = "Monitoring Metrics Publisher"
  principal_id         = data.azurerm_user_assigned_identity.cnpack-cluster-managed-id.principal_id
}
