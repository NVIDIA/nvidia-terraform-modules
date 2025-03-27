# SPDX-FileCopyrightText: Copyright (c) 2022 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.27.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "6.27.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~>2.19.0"
    }
  }

  required_version = ">= 1.2.4"
}
