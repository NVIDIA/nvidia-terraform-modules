# SPDX-FileCopyrightText: Copyright (c) 2023 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

/***************************
CNPack Configuration
***************************/
module "holoscan-ready-gke" {
  source       = "../../" # Can also be the git URL+tag when running remotely
  cluster_name = var.cluster_name
  project_id   = var.project_id
  region       = var.region     # Can be any region
  node_zones   = var.node_zones # Can be any region but ensure your desired machine types/gpus exist
  gpu_operator_namespace_labels = {
    "platform.nvidia.com/monitoring" = "enabled"
  }
}

