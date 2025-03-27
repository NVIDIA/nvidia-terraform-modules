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
  }

  required_version = ">= 1.0.0"
}
