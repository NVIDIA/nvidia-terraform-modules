# SPDX-FileCopyrightText: Copyright (c) 2022 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

#!/bin/bash

_aws_profile=$(echo "$input" | jq -r '.aws_profile')
_aws_region=$(echo "$input" | jq -r '.aws_region')
_eks_cluster_name=$(echo "$input" | jq -r '.eks_cluster_name')
_eks_cluster_arn=$(echo "$input" | jq -r '.eks_cluster_arn')

if aws --profile "${_aws_profile}" eks update-kubeconfig --region "${_aws_region}" --name "${_eks_cluster_name}" 1> /dev/null 2>&1; then
  jq -n --arg command_to_use "kubectl config use-context ${_eks_cluster_arn}" '{"status":"success","commandToUse":$command_to_use}'
else
  jq -n '{"status":"failure"}'
fi
