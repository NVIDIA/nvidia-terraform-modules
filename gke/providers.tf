# SPDX-FileCopyrightText: Copyright (c) 2022-2023 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

provider "kubernetes" {
  host  = "https://${google_container_cluster.holoscan.endpoint}"
  token = data.google_client_config.provider.access_token
  cluster_ca_certificate = base64decode(
    google_container_cluster.holoscan.master_auth.0.cluster_ca_certificate,
  )
}

provider "helm" {
  kubernetes {
    token = data.google_client_config.provider.access_token
    host  = "https://${google_container_cluster.holoscan.endpoint}"
    cluster_ca_certificate = base64decode(
      google_container_cluster.holoscan.master_auth.0.cluster_ca_certificate,
    )
  }
}
