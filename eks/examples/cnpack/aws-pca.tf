# SPDX-FileCopyrightText: Copyright (c) 2023 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

/*******************************************
AWS Private Cert Authority Config
*******************************************/

// Create AWS Private Cert Authority
resource "aws_acmpca_certificate_authority" "cnpack-pca" {
  count = var.pca_enabled ? 1 : 0
  type  = "ROOT"
  certificate_authority_configuration {
    key_algorithm     = "RSA_4096"
    signing_algorithm = "SHA512WITHRSA"

    subject {
      common_name = var.common_name
    }
  }

  permanent_deletion_time_in_days = 7
}

data "aws_partition" "current" {}

// Configure AWS Private Cert Authority  to have a certificate
resource "aws_acmpca_certificate" "cnpack-pca" {
  count                       = var.pca_enabled ? 1 : 0
  certificate_authority_arn   = aws_acmpca_certificate_authority.cnpack-pca[count.index].arn
  certificate_signing_request = aws_acmpca_certificate_authority.cnpack-pca[count.index].certificate_signing_request
  signing_algorithm           = "SHA512WITHRSA"

  template_arn = "arn:${data.aws_partition.current.partition}:acm-pca:::template/RootCACertificate/V1"

  validity {
    type  = "YEARS"
    value = 1
  }
}

// Output the PCA Arn for use in CNPack
output "aws_pca_arn" {
  value = var.pca_enabled == false ? null : aws_acmpca_certificate_authority.cnpack-pca[0].arn
}
// An ACM PCA Certificate Authority is unable to issue certificates until it has a certificate associated with it. 
// A root level ACM PCA Certificate Authority is able to self-sign its own root certificate.

resource "aws_acmpca_certificate_authority_certificate" "cnpack-pca" {
  count                     = var.pca_enabled ? 1 : 0
  certificate_authority_arn = aws_acmpca_certificate_authority.cnpack-pca[count.index].arn

  certificate       = aws_acmpca_certificate.cnpack-pca[count.index].certificate
  certificate_chain = aws_acmpca_certificate.cnpack-pca[count.index].certificate_chain
}

resource "aws_acmpca_permission" "cnpack-pca" {
  count                     = var.pca_enabled ? 1 : 0
  certificate_authority_arn = aws_acmpca_certificate_authority.cnpack-pca[count.index].arn
  actions                   = ["IssueCertificate", "GetCertificate", "ListPermissions"]
  principal                 = "acm.amazonaws.com"
}

// Create a random string to attach to IAM policy
// This prevents naming collisions when this module is run more than once in the same AWS account
resource "random_string" "pca" {
  count   = var.pca_enabled ? 1 : 0
  length  = 3
  special = false
  upper   = false
}

// Create IAM policy using the random string to prevent IAM naming collision
resource "aws_iam_policy" "pca-policy" {
  count       = var.pca_enabled ? 1 : 0
  name        = "aws-pca-node-role-policy-${random_string.pca[count.index].result}"
  description = "Policy to use AWS AMP"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "VisualEditor0",
        "Effect" : "Allow",
        "Action" : [
          "acm-pca:IssueCertificate",
          "acm-pca:GetCertificate",
          "acm-pca:DescribeCertificateAuthority"
        ],
        "Resource" : aws_acmpca_certificate_authority.cnpack-pca[count.index].arn
      }
    ]
  })
}

// IAM Policy to attach to node roles for PCA to work on GPU nodes
resource "aws_iam_role_policy_attachment" "attach-gpu-node-policy" {
  count      = var.pca_enabled ? 1 : 0
  role       = module.holoscan-eks-cluster.gpu_node_role_name
  policy_arn = aws_iam_policy.pca-policy[count.index].arn
}
// IAM Policy to attach to node roles for PCA to work on CPU nodes
resource "aws_iam_role_policy_attachment" "attach-cpu-node-policy" {
  count      = var.pca_enabled ? 1 : 0
  role       = module.holoscan-eks-cluster.cpu_node_role_name
  policy_arn = aws_iam_policy.pca-policy[count.index].arn
}
