# SPDX-FileCopyrightText: Copyright (c) 2022-2024 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

# Sample tfvars file. Uncomment out values to use
# Do not commit this file to Git with sensitive values


########################
#  CLUSTER PARAMETERS  #
########################
# For Instances refer https://docs.aws.amazon.com/dlami/latest/devguide/gpu.html


# cluster_name                          = "eks-cluster-tf"
# cluster_version                       = "1.32"
# aws_region                            = "us-west-2"


# additional_node_security_groups_rules = {}
# additional_security_group_ids         = []
# additional_user_data                  = ""
# aws_profile                           = "development"
# cidr_block                            = "10.0.0.0/16"
# cpu_instance_type                     = "t2.xlarge"
# cpu_node_pool_additional_user_data    = ""
# cpu_node_pool_delete_on_termination   = true
# cpu_node_pool_root_disk_size_gb       = 512
# cpu_node_pool_root_volume_type        = "gp2"
# desired_count_cpu_nodes               = "1"
# desired_count_gpu_nodes               = "2"
# enable_dns_hostnames                  = true
# enable_dns_support                    = true
# enable_nat_gateway                    = true
# existing_vpc_details                  = ""
# gpu_ami_id                            = ""
# gpu_instance_type                     = "g4dn.2xlarge"
# gpu_node_pool_additional_user_data    = ""
# gpu_node_pool_delete_on_termination   = true
# gpu_node_pool_root_disk_size_gb       = 512
# gpu_node_pool_root_volume_type        = "gp2"
# max_cpu_nodes                         = "2"
# max_gpu_nodes                         = "5"
# min_cpu_nodes                         = "0"
# min_gpu_nodes                         = "1"
# private_subnets = [
#   "10.0.0.0/19",
#   "10.0.32.0/19",
#   "10.0.64.0/19"
# ]
# public_subnets = [
#   "10.0.96.0/19",
#   "10.0.128.0/19",
#   "10.0.160.0/19"
# ]
# single_nat_gateway = false
# ssh_key            = ""


########################
# GPU OPERATOR         #
########################

#install_gpu_operator                  = "true"
#gpu_operator_driver_version           = "570.124.06"
#gpu_operator_namespace                = "gpu-operator"
#gpu_operator_version                  = "v25.3.0"


########################
# NIM OPERATOR         #
########################

# install_nim_operator                  = "false"
# nim_operator_version                  = "v1.0.0"
# nim_operator_namespace                = "nim-operator"

