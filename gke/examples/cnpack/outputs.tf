# SPDX-FileCopyrightText: Copyright (c) 2023 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

/*******************************************
CNPack Example Outputs
*******************************************/

output "gcp_service_account_email_for_prometheus" {
  value = module.managed-prometheus-workload-identity[0].gcp_service_account_email
}