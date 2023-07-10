# SPDX-FileCopyrightText: Copyright (c) 2023 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

/*******************************************
Holoscan Cluster Variables
*******************************************/
variable "cluster_name" {
  type        = string
  description = "Name of the cluster"
}

/*******************************************
AWS Managed Prometheus Variables
*******************************************/
variable "amp_enabled" {
  type        = bool
  default     = true
  description = "Set to true to enable, false to disable"
}

/*******************************************
AWS Private Certificate Authority Variables
*******************************************/
variable "pca_enabled" {
  type        = bool
  default     = true
  description = "Set to true to enable, false to disable"
}

variable "common_name" {
  type        = string
  default     = "cluster.local"
  description = "Common Name for PCA Creation"
}

/*******************************************
AWS Fluentbit Variables
*******************************************/
variable "fluentbit_enabled" {
  type        = bool
  default     = true
  description = "Set to true to enable, false to disable"
}

/*******************************************
Prometheus Adapter Variables
*******************************************/
variable "prom_adapter_enabled" {
  type        = bool
  default     = true
  description = "Set to true to enable the network support for Prometheus Adapter, false to disable"
}
/*******************************************
Metrics Server Variables
*******************************************/
variable "metrics_server_enabled" {
  type        = bool
  default     = true
  description = "Set to true to enable the network support for Metrics Server, false to disable"
}
