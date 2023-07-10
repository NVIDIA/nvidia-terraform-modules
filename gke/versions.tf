# SPDX-FileCopyrightText: Copyright (c) 2022 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.27.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "4.57.0"
    }
  }

  required_version = ">= 0.14"
}

