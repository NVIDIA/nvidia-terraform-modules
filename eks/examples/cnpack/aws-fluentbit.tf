# SPDX-FileCopyrightText: Copyright (c) 2023-2024 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

/*******************************************
Fluentbit Config
*******************************************/

// Get preexisting policy for Cloudwatch to pass in the arn in the next config block
data "aws_iam_policy" "cloudwatch-agent-server-policy" {
  count = var.fluentbit_enabled ? 1 : 0
  name  = "CloudWatchAgentServerPolicy"
}

// IAM Policy to attach GPU node pools to Amazon Managed Cloud Watch Policy
resource "aws_iam_role_policy_attachment" "attach-cloudwatch-to-gpu-ng" {
  count      = var.fluentbit_enabled ? 1 : 0
  role       = module.holoscan-eks-cluster.gpu_node_role_name
  policy_arn = data.aws_iam_policy.cloudwatch-agent-server-policy[count.index].arn
}

// IAM Policy to attach CPU node pools to Amazon Managed Cloud Watch Policy
resource "aws_iam_role_policy_attachment" "attach-cloudwatch-to-cpu-ng" {
  count      = var.fluentbit_enabled ? 1 : 0
  role       = module.holoscan-eks-cluster.cpu_node_role_name
  policy_arn = data.aws_iam_policy.cloudwatch-agent-server-policy[count.index].arn
}
