# SPDX-FileCopyrightText: Copyright (c) 2022-2024 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

# Sample tfvars file. Uncomment out values to use
# Do not commit this file to Git with sensitive values


########################
#  CLUSTER PARAMETERS  #
########################

# MANDATORY PARAMETER: project_id
# Uncomment and Modify other parameters if needed
# Useful link: https://cloud.google.com/kubernetes-engine/docs/how-to/gpus#limitations 

project_id                          = "xx-xxxx-xxxx"

# cluster_name                      = "gke-cluster"
# min_master_version                = "1.32"
# cpu_instance_type                 = "n1-standard-4"
# cpu_max_node_count                = "5"
# cpu_min_node_count                = "1"
# disk_size_gb                      = "512"
# gpu_count                         = "1"
# gpu_instance_tags                 = []
# gpu_instance_type                 = "n1-standard-4"
# gpu_max_node_count                = "5"
# gpu_min_node_count                = "2"
# gpu_type                          = "nvidia-tesla-t4"
# network                           = ""
# num_cpu_nodes                     = 1
# num_gpu_nodes                     = 1
# region                            = "us-west1"
# node_zones                        = ["us-west1-b"]
# release_channel                   = "REGULAR"
# subnetwork                        = ""
# use_cpu_spot_instances            = false
# use_gpu_spot_instances            = false
# vpc_enabled                       = true


########################
# GPU OPERATOR         #
########################

# install_gpu_operator              = "true"
# gpu_operator_driver_version       = "570.124.06"
# gpu_operator_namespace            = "gpu-operator"
# gpu_operator_version              = "v25.4.0"


########################
# NIM OPERATOR         #
########################

# install_nim_operator              = "false"
# nim_operator_version              = "v1.0.1"
# nim_operator_namespace            = "nim-operator"

