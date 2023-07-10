# SPDX-FileCopyrightText: Copyright (c) 2022-2023 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

/****************************
Azure Variables
****************************/

variable "location" {
  description = "The region to create resources in. This can be filed out in the terraform.tfvars file in this directory"
}

variable "az_monitor-user-managed-id" {
  type        = string
  default     = "tf-holoscan-identity"
  description = "The user managed identity to *create* for use with the Azure monitor-- at this time this does not accept existing user or system managed identity"
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
/*******************************************
Holoscan Cluster Variables
*******************************************/
variable "cluster_name" {
  type        = string
  description = "Name of the cluster"
}

/*******************************************
Fluentbit (Azure Logging) Variables
*******************************************/
variable "fluentbit_enabled" {
  type        = bool
  default     = true
  description = "Set to true to enable, false to disable"
}

variable "fluentbit-workspace-name" {
  description = "Name of the Azure Log Workspace for Fluentbit to be created"
  type        = string
}

variable "azure_log_analytics_sku" {
  description = "Specifies the SKU of the Log Analytics Workspace. Possible values are Free, PerNode, Premium, Standard, Standalone, Unlimited, CapacityReservation, and PerGB2018. Defaults to PerGB2018"
  default     = "PerGB2018"
}

variable "azure_log_analytics_retention_in_days" {
  default     = 30
  description = "The workspace data retention in days. Possible values are either 7 (Free Tier only) or range between 30 and 730"
}

/*******************************************
Prometheus (Azure Monitor) Variables
*******************************************/
variable "prometheus_resource_group_name" {
  default     = "prometheus-rg"
  description = "Name of the Prometheus resource group"
}
variable "prometheus-name" {
  type        = string
  description = "The name of the Azure Monitor Workspace for Prometheus"
}