# SPDX-FileCopyrightText: Copyright (c) 2022-2023 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

data "azurerm_resource_group" "existing" {
  count = var.existing_resource_group_name == null ? 0 : 1
  name  = var.existing_resource_group_name
}

resource "azurerm_resource_group" "aks" {
  count    = var.existing_resource_group_name == null ? 1 : 0
  name     = "${var.cluster_name}-rg"
  location = var.location
  tags = {
    group      = "aks"
    managed_by = "Terraform"
  }
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  kubernetes_version  = var.kubernetes_version
  resource_group_name = var.existing_resource_group_name == null ? azurerm_resource_group.aks[0].name : data.azurerm_resource_group.existing[0].name
  location            = var.existing_resource_group_name == null ? azurerm_resource_group.aks[0].location : data.azurerm_resource_group.existing[0].location
  dns_prefix          = var.cluster_name

  default_node_pool {
    name                = "akscpu"
    node_count          = var.cpu_node_pool_count
    enable_auto_scaling = true
    min_count           = var.cpu_node_pool_min_count
    max_count           = var.cpu_node_pool_max_count
    vm_size             = var.cpu_machine_type
    os_disk_size_gb     = var.cpu_node_pool_disk_size
  }

  azure_active_directory_role_based_access_control {
    managed                = true
    azure_rbac_enabled     = true
    admin_group_object_ids = var.admin_group_object_ids
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    group      = "aks"
    managed_by = "Terraform"
  }

  // As the cluster is being created, have the az CLI update the users kubeconfig file
  provisioner "local-exec" {
    command = "az aks get-credentials --resource-group ${var.existing_resource_group_name == null ? azurerm_resource_group.aks[0].name : data.azurerm_resource_group.existing[0].name} --name ${var.cluster_name} --overwrite-existing"
  }

  provisioner "local-exec" {
    command = "kubelogin convert-kubeconfig -l azurecli"
  }
}

data "azurerm_kubernetes_cluster" "akscluster" {
  name                = azurerm_kubernetes_cluster.aks.name
  resource_group_name = var.existing_resource_group_name == null ? azurerm_resource_group.aks[0].name : data.azurerm_resource_group.existing[0].name
  depends_on          = [azurerm_kubernetes_cluster.aks]
}

resource "azurerm_kubernetes_cluster_node_pool" "aks" {
  depends_on            = [azurerm_kubernetes_cluster.aks]
  name                  = "aksgpu1"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  node_count            = var.gpu_node_pool_count
  enable_auto_scaling   = true
  min_count             = var.gpu_node_pool_min_count
  max_count             = var.gpu_node_pool_max_count
  vm_size               = var.gpu_machine_type
  os_disk_size_gb       = var.gpu_node_pool_disk_size
  tags = {
    group      = "aks"
    managed_by = "Terraform"
    SkipGPUDriverInstall = true
  }
}

/***************************
Create GPU Operator Namespace
***************************/
resource "kubernetes_namespace_v1" "gpu-operator" {
  metadata {
    annotations = {
      name = "gpu-operator"
    }

    labels = {
      cluster    = var.cluster_name
      managed_by = "Terraform"
    }

    name = var.gpu_operator_namespace
  }
}

/***************************
GPU Operator Configuration
***************************/
resource "helm_release" "gpu-operator" {
  depends_on       = [azurerm_kubernetes_cluster_node_pool.aks, kubernetes_namespace_v1.gpu-operator]
  count            = var.install_gpu_operator ? 1 : 0
  name             = "gpu-operator"
  repository       = "https://helm.ngc.nvidia.com/nvidia"
  chart            = "gpu-operator"
  version          = var.gpu_operator_version
  namespace        = var.gpu_operator_namespace
  create_namespace = false
  atomic           = true
  cleanup_on_fail  = true
  reset_values     = true
  replace          = true

  set {
    name  = "toolkit.enabled"
    value = "true"
  }

  set {
    name  = "operator.cleanupCRD"
    value = "true"
  }

  set {
    name  = "driver.enabled"
    value = "true"
  }

  set {
    name  = "driver.version"
    value = var.gpu_operator_driver_version
  }

}

/***************************
Create NIM Operator Namespace
***************************/
resource "kubernetes_namespace_v1" "nim-operator" {
  metadata {
    annotations = {
      name = "nim-operator"
    }

    labels = {
      cluster    = var.cluster_name
      managed_by = "Terraform"
    }

    name = var.nim_operator_namespace
  }
}


/********************************************
 NIM Operator Configuration
********************************************/
resource "helm_release" "nim_operator" {
  depends_on       = [azurerm_kubernetes_cluster_node_pool.aks, kubernetes_namespace_v1.nim-operator]
  count            = var.install_nim_operator ? 1 : 0
  name             = "nim-operator"
  repository       = "https://helm.ngc.nvidia.com/nvidia"
  chart            = "k8s-nim-operator"
  version          = var.nim_operator_version
  namespace        = var.nim_operator_namespace
  create_namespace = true
  atomic           = true
  cleanup_on_fail  = true
  reset_values     = true
  replace          = true
}