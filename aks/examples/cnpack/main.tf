# SPDX-FileCopyrightText: Copyright (c) 2022-2023 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

module "holoscan-ready-aks" {
  source                 = "../../" #if running remotely, path to the repo
  cluster_name           = var.cluster_name
  admin_group_object_ids = var.admin_group_object_ids
  location               = var.location
}

data "azurerm_kubernetes_cluster" "holoscancluster" {
  name                = module.holoscan-ready-aks.kubernetes_cluster_name
  resource_group_name = module.holoscan-ready-aks.resource_group_name
  depends_on          = [module.holoscan-ready-aks]
}
