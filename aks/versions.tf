# SPDX-FileCopyrightText: Copyright (c) 2022 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.48.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~>2.19.0"
    }
  }

  required_version = ">= 1.3.4"
}

