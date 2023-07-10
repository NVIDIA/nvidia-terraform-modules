# SPDX-FileCopyrightText: Copyright (c) 2023 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

/*******************************************
AWS Managed Prometheus Config
*******************************************/

// Create a random suffix to attach to IAM policies and resource names
// This prevents naming collisions when this module is run more than once in the same AWS account
resource "random_string" "amp" {
  count   = var.amp_enabled ? 1 : 0
  length  = 3
  special = false
  upper   = false
}

resource "aws_cloudwatch_log_group" "cnpack-log-group" {
  count = var.amp_enabled ? 1 : 0
  name  = "cnpack-logs-${random_string.amp[count.index].result}"
}

resource "aws_prometheus_workspace" "cnpack-prom-workspace" {
  count = var.amp_enabled ? 1 : 0
  alias = "cnpack-workspace-${random_string.amp[count.index].result}"
  logging_configuration {
    log_group_arn = "${aws_cloudwatch_log_group.cnpack-log-group[count.index].arn}:*"
  }
  tags = {
    Environment = "non-production"
  }
}

// Output Prometheus Remote Write Endpoint
output "amp_remotewrite_endpoint" {
  value = var.amp_enabled == false ? null : "${aws_prometheus_workspace.cnpack-prom-workspace[0].prometheus_endpoint}api/v1/remote_write"
}

// Output Prometheus Query Write Endpoint
output "amp_query_endpoint" {
  value = var.amp_enabled == false ? null : "${aws_prometheus_workspace.cnpack-prom-workspace[0].prometheus_endpoint}api/v1/query"
}

// Create Policy that connects the IAM role for service accounts
resource "aws_iam_policy" "amp-ingest-policy" {
  count       = var.amp_enabled ? 1 : 0
  name        = "aws-amp-remote-write-ingest-policy-${random_string.amp[count.index].result}"
  description = "Policy to connect K8s cluster to AWS AMP"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      { "Effect" : "Allow",
        "Action" : [
          "aps:RemoteWrite",
          "aps:GetSeries",
          "aps:GetLabels",
          "aps:GetMetricMetadata"
        ],
        "Resource" : "*"
      }
    ]
  })
}

data "aws_caller_identity" "current" {}

resource "aws_iam_role" "amp-ingest-role" {
  count = var.amp_enabled ? 1 : 0
  name  = "amp-ingest-role-${random_string.amp[count.index].result}"
  # Terraform's "jsonencode" function converts Terraform expression to valid JSON syntax.
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${module.holoscan-eks-cluster.oidc_endpoint}"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "${module.holoscan-eks-cluster.oidc_endpoint}:sub" : "system:serviceaccount:nvidia-monitoring:nvidia-prometheus-prometheus"
          }
        }
      }
    ]
  })

  tags = {
    managed-by = "terraform"
  }
}

// Attach the AMP Policy to the ingest role
resource "aws_iam_role_policy_attachment" "attach-amp-role-to-policy" {
  count      = var.amp_enabled ? 1 : 0
  role       = aws_iam_role.amp-ingest-role[count.index].name
  policy_arn = aws_iam_policy.amp-ingest-policy[count.index].arn
}
resource "aws_iam_role_policy_attachment" "attach-amp-policy-to-gpu-ng" {
  count      = var.amp_enabled ? 1 : 0
  role       = module.holoscan-eks-cluster.gpu_node_role_name
  policy_arn = aws_iam_policy.amp-ingest-policy[count.index].arn
}
resource "aws_iam_role_policy_attachment" "attach-amp-role-to-cpu-ng" {
  count      = var.amp_enabled ? 1 : 0
  role       = module.holoscan-eks-cluster.cpu_node_role_name
  policy_arn = aws_iam_policy.amp-ingest-policy[count.index].arn
}

output "amp_ingest_role_arn" {
  value = var.pca_enabled == false ? null : aws_iam_role.amp-ingest-role[0].arn
}