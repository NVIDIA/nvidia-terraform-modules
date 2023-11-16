# CNPack EKS Module

This module will add additional AWS specific configuration for use with CNPack

### Resources Created

- AWS Managed Prometheus and corresponding IAM roles

- AWS Private Certificate Authority and corresponding IAM roles

- Node Role Policy for FluentBit connection

- Keycloak deployment (leverages AWS CSI driver to create a 1Gb dynamic PV for Keycloak PVC)

### Requirements

1. The AWS user should have permissions to create an Infrastructure and IAM roles and permissions

2. Requires [CNPack](https://docs.nvidia.com/ai-enterprise/deployment-guide-cloud-native-service-add-on-pack/0.1.0/cns-deployment.html) binary, AWS CLI, Kubectl and [awscurl](https://github.com/okigan/awscurl) optionally to query Prometheus metrics from the command line

3. The AWS region needs to be configured to a region where **Amazon Prometheus, GPU Nodes, and many other resources** are available. For example, Amazon Prometheus is available in [`us-west-2`](https://us-west-2.console.aws.amazon.com/prometheus/home?region=us-west-2#/) but not available in [`us-west-1`](https://console.aws.amazon.com/prometheus/home?region=us-west-1#). Please verify by checking your `~/.aws/config` to make sure that the region reflected is in one of the available regions. If not, please run `aws configure` to configure the region accordingly. We have tested that all of our resources can be created in `us-west-2`.


### Usage

1. From this module run `terraform init`

2. Uncomment/add values in the `terraform.tfvars` file in this directory, otherwise you will be prompted at cluster creation time for values such as `cluster_name`

3. Run `terraform plan -out tfplan` to see what will be applied

4. If everything looks correct, run `terraform apply tfplan`

5. To delete the cluster, run `terraform destroy`


### Running CNPack with the CNPack Holoscan Cluster
1. Once the cluster is created update your kubeconfig:
```bash
aws eks update-kubeconfig --name  tf-<cluster-name>  --region us-west-2 
```
2. Run `terraform output` to get the needed values to populate the CNPack config file

#### Sample Config File

Use the following config file (adding in the outputs from "terraform output") wit CNPack to enable all AWS services tur
```yaml
apiVersion: v1alpha2
kind: NvidiaPlatform
spec:
  platform:
    wildcardDomain: "*.holoscandev.nvidia.com"
    externalPort: 443
    eks:
      region: us-west-2
  certManager:
    enabled: true
    awsPCA:
      enabled: true
      commonName: "cluster.local"
      domainName: "cluster.local"
      arn: "<aws_pca_arn from 'terraform output'>"
  prometheus:
    enabled: true
    awsRemoteWrite:
      url: "<amp_remotewrite_endpoint from 'terraform output'>"
      arn: "<amp_ingest_role_arn from 'terraform output'>"
  prometheusAdapter:
    enabled: true
  fluentbit:
    enabled: true
  trustManager:
    enabled: false
  keycloak:
    enabled: true
    databaseStorage:
      accessModes:
        - ReadWriteOnce
      resources:
        requests:
          storage: 1G
      storageClassName: gp2
  grafana:
    customHostname: grafana.cluster.local
    enabled: false
  elastic:
    enabled: false
  ingress:
    enabled: false
  postgres:
    enabled: true
```

### Certmanager with AWS PCA Plugin

#### Usage
1. Run `terraform output` to get the outputs from the CNPack cluster example

2. Grab the value from the console output for the variable `aws_pca_arn` and enter value in `certManager.awsPCA.arn`

3. Ensure `awsPCA.enabled` is set to `true`

4. Run `cnpack install -f nvidiaplatform.yaml`

5. Run `kubectl get po -n nvidia-platform` and check that a pod named `nvidia-platform-aws-privateca-issuer-<random-number>` exists

#### Validation
1. To validate the AWS PCA Cluster issuer is installed correctly and ready to issue certificates run `kubectl get awspcaclusterissuers.awspca.cert-manager.io`

2. There is a test certificate in this directory `testcert.yaml`, run `kubectl apply -f testcert.yaml`, followed by `kubectl get cert -A`. Under `READY` it should be `True` for the certificate `rsa-cert-4096`


### AWS Managed Prometheus (AMP)

#### Usage
1. Run `terraform output` to get the outputs from the CNPack cluster example

2. Grab the value from the console output for the variable `amp_remotewrite_endpoint` and enter value in `prometheus.awsRemoteWrite.url`

3. Grab the value from the console output for the variable `amp_ingest_role_arn` and enter value in `prometheus.awsRemoteWrite.arn`

4. Ensure `awsPCA.enabled` is set to `true`

5. Run `cnpack install -f nvidiaplatform.yaml`

#### Validation
1. Check Prometheus logs by running `kubectl logs -n nvidia-monitoring prometheus-nvidia-prometheus-kube-pro-prometheus-0`. You should see no errors within the prometheus pod.

2. Download [awscurl](https://github.com/okigan/awscurl) -- eg: `pip install awscurl`

3. Take the Terraform output for `amp_query_endpoint` and export it as an environment variable with the following:
```bash
export AMP_QUERY_ENDPOINT=<amp_query_endpoint>
```
4. Query that the Managed Prometheus is up and running:
```bash
awscurl -X POST --region us-west-2 --service aps ${AMP_QUERY_ENDPOINT}\?query=up  
```

5. You can view the AWS Managed Prometheus workspace which was created [here](https://us-west-2.console.aws.amazon.com/prometheus/home?region=us-west-2#/workspaces) 

### Flutentbit to CloudWatch Logging

#### Usage

1. Ensure `awsPCA.enabled` is set to `true`

2. Run `cnpack install -f nvidiaplatform.yaml`

#### Validation

1. Check that the Fluentbit pod is in a running state:
```bash
kubectl get po -n nvidia-monitoring
```
You should see 2x `Running` pods named `nvidia-fluentbit-aws-for-fluentbit-<random_number>`

2. Head to the AWS Console for [CloudWatch Log Groups](https://us-west-2.console.aws.amazon.com/cloudwatch/home?region=us-west-2#logsV2:log-groups)

3. Search for a log group named `/aws/eks/fluentbit-cloudwatch/workload/<namespace>`. Once you click on this log group, you should see application logs for the entire cluster.


### Troubleshooting


1. Error creating Prometheus Workspace - no such host
```
│ Error: creating Prometheus Workspace: RequestError: send request failed

│ caused by: Post "https://aps.us-west-1.amazonaws.com/workspaces": dial tcp: lookup aps.us-west-1.amazonaws.com on 127.0.0.53:53: no such host
```

**FIX**: Please see [Requirements#3](#requirements) to verify that your AWS region is configured correctly.


## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.45.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.5.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_holoscan-eks-cluster"></a> [holoscan-eks-cluster](#module\_holoscan-eks-cluster) | ../.. | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_acmpca_certificate.cnpack-pca](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acmpca_certificate) | resource |
| [aws_acmpca_certificate_authority.cnpack-pca](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acmpca_certificate_authority) | resource |
| [aws_acmpca_certificate_authority_certificate.cnpack-pca](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acmpca_certificate_authority_certificate) | resource |
| [aws_acmpca_permission.cnpack-pca](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acmpca_permission) | resource |
| [aws_cloudwatch_log_group.cnpack-log-group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_policy.amp-ingest-policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.pca-policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.amp-ingest-role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.attach-amp-policy-to-gpu-ng](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.attach-amp-role-to-cpu-ng](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.attach-amp-role-to-policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.attach-cloudwatch-to-cpu-ng](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.attach-cloudwatch-to-gpu-ng](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.attach-cpu-node-policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.attach-gpu-node-policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_prometheus_workspace.cnpack-prom-workspace](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/prometheus_workspace) | resource |
| [random_string.amp](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [random_string.pca](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy.cloudwatch-agent-server-policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_amp_enabled"></a> [amp\_enabled](#input\_amp\_enabled) | Set to true to enable, false to disable | `bool` | `true` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the cluster | `string` | n/a | yes |
| <a name="input_common_name"></a> [common\_name](#input\_common\_name) | Common Name for PCA Creation | `string` | `"cluster.local"` | no |
| <a name="input_fluentbit_enabled"></a> [fluentbit\_enabled](#input\_fluentbit\_enabled) | Set to true to enable, false to disable | `bool` | `true` | no |
| <a name="input_metrics_server_enabled"></a> [metrics\_server\_enabled](#input\_metrics\_server\_enabled) | Set to true to enable the network support for Metrics Server, false to disable | `bool` | `false` | no |
| <a name="input_pca_enabled"></a> [pca\_enabled](#input\_pca\_enabled) | Set to true to enable, false to disable | `bool` | `true` | no |
| <a name="input_prom_adapter_enabled"></a> [prom\_adapter\_enabled](#input\_prom\_adapter\_enabled) | Set to true to enable the network support for Prometheus Adapter, false to disable | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_amp_ingest_role_arn"></a> [amp\_ingest\_role\_arn](#output\_amp\_ingest\_role\_arn) | n/a |
| <a name="output_amp_query_endpoint"></a> [amp\_query\_endpoint](#output\_amp\_query\_endpoint) | Output Prometheus Query Write Endpoint |
| <a name="output_amp_remotewrite_endpoint"></a> [amp\_remotewrite\_endpoint](#output\_amp\_remotewrite\_endpoint) | Output Prometheus Remote Write Endpoint |
| <a name="output_aws_pca_arn"></a> [aws\_pca\_arn](#output\_aws\_pca\_arn) | Output the PCA Arn for use in CNPack |
