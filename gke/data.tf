# SPDX-FileCopyrightText: Copyright (c) 2022 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

data "google_container_cluster" "holoscan-cluster" {
  name     = var.cluster_name
  location = var.region
}

data "google_client_config" "provider" {}

data "google_project" "cluster" {}