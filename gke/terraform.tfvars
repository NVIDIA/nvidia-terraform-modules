# SPDX-FileCopyrightText: Copyright (c) 2022-2024 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

# Sample tfvars file. Uncomment out values to use
# Do not commit this file to Git with sensitive values

cluster_name                      = "gke-cluster"
# cpu_instance_type                 = "n1-standard-4"
# cpu_max_node_count                = "5"
# cpu_min_node_count                = "1"
# disk_size_gb                      = "512"
# gpu_count                         = "1"
# gpu_instance_tags                 = []
#https://cloud.google.com/kubernetes-engine/docs/how-to/gpus#limitations
# gpu_instance_type                 = "n1-standard-4"
# gpu_max_node_count                = "5"
# gpu_min_node_count                = "2"
install_gpu_operator              = "true"
# gpu_operator_driver_version       = "550.127.05"
# gpu_operator_namespace            = "gpu-operator"
# gpu_operator_version              = "v24.9.0"
# gpu_type                          = "nvidia-tesla-v100"
# min_master_version                = "1.30"
# install_nim_operator              = "false"
# nim_operator_version              = "v1.0.0"
# nim_operator_namespace            = "nim-operator"
# network                           = ""
# num_cpu_nodes                     = 1
# num_gpu_nodes                     = 1
project_id                        = "xx-xxxx-xxxx"
region                            = "us-west1"
node_zones                        =  ["us-west1-b"]
# release_channel                   = "REGULAR"
# subnetwork                        = ""
# use_cpu_spot_instances            = false
# use_gpu_spot_instances            = false
# vpc_enabled                       = true