# SPDX-FileCopyrightText: Copyright (c) 2023 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

data "google_client_config" "gke" {}

provider "kubernetes" {
  host  = "https://${module.holoscan-ready-gke.kubernetes_cluster_endpoint_ip}"
  token = data.google_client_config.gke.access_token
  cluster_ca_certificate = base64decode(
    module.holoscan-ready-gke.kubernetes_config_file,
  )
}
