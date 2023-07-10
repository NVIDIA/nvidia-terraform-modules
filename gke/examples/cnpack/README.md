# CNPack GKE Module

This module will add additional GKE specific configuration for use with the [Cloud Native Service add-on Pack (CNPack)](https://docs.nvidia.com/ai-enterprise/deployment-guide-cloud-native-service-add-on-pack/0.1.0/cns-deployment.html)

### Resources Created

- GCP IAM Service Account specifically for use with Workload Identity
- Workload Identity binding the needed scopes for GCP Managed Prometheus to the above Service Account
- GKE Cluster from the root module (1x CPU node, 1x GPU node + GPU Operator)

### Requirements

1. The GCP user should have permissions to create a GKE Cluster, IAM users, and bind IAM roles

2. Requires [CNPack](https://docs.nvidia.com/ai-enterprise/deployment-guide-cloud-native-service-add-on-pack/0.1.0/cns-deployment.html) binary, GCloud CLI (to connect to the GKE cluster once provisioned), Kubectl

### Usage

1. From this module run `terraform init`

2. Uncomment/add values in the `terraform.tfvars` file in this directory, otherwise you will be prompted at cluster creation time for values such as `cluster_name` and `project_id`

3. Run `terraform plan -out tfplan` to see what the proposed changes are

4. If everything looks correct, run `terraform apply tfplan`

4. To delete the cluster, run `module.holoscan-ready-gke.kubernetes_resource_quota_v1.gpu-operator-quota` then run `terraform destroy`


### Running CNPack with the CNPack Holoscan Cluster
1. Once the cluster is created update your kubeconfig:
```bash
gcloud beta container clusters get-credentials <cluster-name> --region <region> --project <project-id>
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
  gke: {}
 ingress:
  enabled: false
 postgres:
  enabled: false
 certManager:
  enabled: true
 prometheus:
  enabled: true
  gkeRemoteWrite:
    gcpServiceAccount: <gcp_service_account_email_for_prometheus from TF Output>
 trustManager:
  enabled: false
 keycloak:
  enabled: false
 fluentbit:
  enabled: true
 grafana:
  customHostname: grafana.holoscandev.com
  enabled: false
 elastic:
  enabled: false
```
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_holoscan-ready-gke"></a> [holoscan-ready-gke](#module\_holoscan-ready-gke) | ../../ | n/a |
| <a name="module_managed-prometheus-workload-identity"></a> [managed-prometheus-workload-identity](#module\_managed-prometheus-workload-identity) | terraform-google-modules/kubernetes-engine/google//modules/workload-identity | n/a |

## Resources

| Name | Type |
|------|------|
| [google_service_account.prometheus_service_account](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the Kubernetes Cluster to provision | `string` | n/a | yes |
| <a name="input_gke_managed_prometheus_enabled"></a> [gke\_managed\_prometheus\_enabled](#input\_gke\_managed\_prometheus\_enabled) | Set to true to enable, false to disable | `bool` | `true` | no |
| <a name="input_node_zones"></a> [node\_zones](#input\_node\_zones) | Specify zones to put nodes in (must be in same region defined above) | `list(string)` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP Project ID for the VPC and K8s Cluster. This module currently does not support projects with a SharedVPC | `any` | n/a | yes |
| <a name="input_prometheus_roles"></a> [prometheus\_roles](#input\_prometheus\_roles) | Roles for GKE Workload Identity for Managed Prometheus | `list(string)` | <pre>[<br>  "roles/container.admin",<br>  "roles/iam.serviceAccountAdmin"<br>]</pre> | no |
| <a name="input_region"></a> [region](#input\_region) | The Region resources (VPC, GKE, Compute Nodes) will be created in | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_gcp_service_account_email_for_prometheus"></a> [gcp\_service\_account\_email\_for\_prometheus](#output\_gcp\_service\_account\_email\_for\_prometheus) | n/a |