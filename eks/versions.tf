# SPDX-FileCopyrightText: Copyright (c) 2022-2023 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>4.45.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~>2.19.0"
    }
  }

  required_version = ">= 1.2.4"
}
