# SPDX-FileCopyrightText: Copyright (c) 2022-2023 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

/********************************************
  Network Config
********************************************/
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "4.0.2"
  count   = var.existing_vpc_details == null ? 1 : 0
  name    = "tf-${var.cluster_name}-vpc"
  cidr    = var.cidr_block
  azs     = data.aws_availability_zones.available.names
  # FUTURE: Make configurable, or set statically for the max number of pods a cluster can handle
  private_subnets         = var.private_subnets
  public_subnets          = var.public_subnets
  enable_nat_gateway      = var.enable_nat_gateway
  single_nat_gateway      = var.single_nat_gateway # Future: Revisit the VPC defaults
  enable_dns_hostnames    = var.enable_dns_hostnames
  map_public_ip_on_launch = true
}


/********************************************
  Kubernetes Cluster Configuration
********************************************/

locals {
  holoscan_node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node ingress, no external ingress"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }

    egress_all = {
      description      = "Node egress to open internet"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }
}

module "eks" {
  source                          = "terraform-aws-modules/eks/aws"
  version                         = "18.29.0"
  cluster_name                    = "tf-${var.cluster_name}"
  cluster_version                 = var.cluster_version
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  create_cloudwatch_log_group     = false
  vpc_id                          = var.existing_vpc_details == null ? module.vpc[0].vpc_id : var.existing_vpc_details.vpc_id
  enable_irsa                     = true
  subnet_ids                      = var.existing_vpc_details == null ? module.vpc[0].private_subnets : var.existing_vpc_details.subnet_ids
  control_plane_subnet_ids        = var.existing_vpc_details == null ? module.vpc[0].private_subnets : var.existing_vpc_details.subnet_ids
  # KMS Config
  create_kms_key                  = true
  enable_kms_key_rotation         = true
  kms_key_deletion_window_in_days = 7
  kms_key_enable_default_policy   = true
  cluster_encryption_config = [
    {
      resources : ["secrets"]
    }
  ]
  # Cluster Security Group
  cluster_security_group_additional_rules = {
    egress_nodes_ephemeral_ports_tcp = {
      description                = "Control plane egress to nodes on TCP Ports 1025-65535"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "egress"
      source_node_security_group = true
    }
  }
  # NodeGroup Config
  node_security_group_additional_rules = merge(local.holoscan_node_security_group_additional_rules, var.additional_node_security_groups_rules)

  eks_managed_node_groups = {
    gpu_node_pool = {
      name                       = "tf-gpu"
      instance_types             = [var.gpu_instance_type]
      min_size                   = var.min_gpu_nodes
      max_size                   = var.max_gpu_nodes
      desired_size               = var.desired_count_gpu_nodes
      ami_id                     = data.aws_ami.lookup.id
      ami_type                   = "CUSTOM"
      enable_bootstrap_user_data = true
      post_bootstrap_user_data   = var.gpu_node_pool_additional_user_data
      vpc_security_group_ids     = var.existing_vpc_details == null ? [] : var.additional_security_group_ids
      block_device_mappings = {
        root = {
          device_name = data.aws_ami.lookup.root_device_name
          ebs = {
            volume_size           = var.gpu_node_pool_root_disk_size_gb
            volume_type           = var.gpu_node_pool_root_volume_type
            delete_on_termination = var.gpu_node_pool_delete_on_termination
          }
        }
      }
      ssh_key = var.ssh_key

    },
    cpu_node_pool = {
      name                   = "tf-cpu"
      instance_types         = [var.cpu_instance_type]
      min_size               = var.min_cpu_nodes
      max_size               = var.max_cpu_nodes
      desired_size           = var.desired_count_cpu_nodes
      vpc_security_group_ids = var.existing_vpc_details == null ? [] : var.additional_security_group_ids
      ssh_key                = var.ssh_key
      block_device_mappings = {
        root = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = var.cpu_node_pool_root_disk_size_gb
            volume_type           = var.cpu_node_pool_root_volume_type
            delete_on_termination = var.cpu_node_pool_delete_on_termination
          }
        }
      }
    }
  }
  # Cluster Add-on Config
  cluster_addons = {
    aws-ebs-csi-driver = {
      service_account_role_arn = module.ebs_csi_irsa_role.iam_role_arn
      most_recent              = true
    }
  }
}

/********************************************
  Configure AWS Role for Service Account
  for EKS CSI Driver
********************************************/
module "ebs_csi_irsa_role" {
  source                = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name             = "${var.cluster_name}-ebs-csi"
  attach_ebs_csi_policy = true
  oidc_providers = {
    cluster = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
}

/********************************************
  Custom AMI Lookup
********************************************/
locals {
  ubuntu_ami_lookup = {
    owners = ["099720109477"] # Canonical
    filters = [
      {
        name   = "name"
        values = ["ubuntu-eks/k8s_${var.cluster_version}/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
      },
      {
        name   = "virtualization-type"
        values = ["hvm"]
      }
    ]
  }
  no_ami_lookup = {
    owners  = []
    filters = []
  }
  ami_lookup = var.gpu_ami_id == "" ? local.ubuntu_ami_lookup : local.no_ami_lookup
  ami_id     = var.gpu_ami_id == "" ? data.aws_ami.lookup.id : var.gpu_ami_id
}

/********************************************
  GPU Operator Configuration
********************************************/
resource "helm_release" "gpu_operator" {
  count            = length(data.aws_instances.nodes) > 0 ? 1 : 0
  name             = "gpu-operator"
  repository       = "https://helm.ngc.nvidia.com/nvidia"
  chart            = "gpu-operator"
  version          = var.nvaie == false ? var.gpu_operator_version : var.nvaie_gpu_operator_version
  namespace        = var.gpu_operator_namespace
  create_namespace = true
  atomic           = true
  cleanup_on_fail  = true
  reset_values     = true
  replace          = true

  set {
    name  = "driver.version"
    value = var.nvaie == false ? var.gpu_operator_driver_version : var.nvaie_gpu_operator_driver_version
  }

}

