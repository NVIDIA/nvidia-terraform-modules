# SPDX-FileCopyrightText: Copyright (c) 2022 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

data "google_container_cluster" "holoscan-cluster" {
  name     = var.cluster_name
  location = var.region
  project  = var.project_id
}

data "google_client_config" "provider" {}

data "google_project" "cluster" {
  project_id = var.project_id
}