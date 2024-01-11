# NVIDIA GKE Cluster

This repo provides Terraform configuration to bring up a GKE Kubernetes Cluster with the GPU operator and GPU nodes from scratch.


## Tested on
This module was created with and tested on Linux using Bash, it may or may not work on Windows or when using Powershell.

## Resources Created
- VPC Network for GKE Cluster
- Subnet in VPC
- GKE Cluster
- 1x CPU nodepool (defaults to 1x CPU node -- n1-standard-4)
- 2x GPU nodepool (defaults to 1x V100 -- n1-standard-4 with 1x Tesla V100)
- Installs latest version of GPU Operator via Helm 

## Prerequisites
1. Kubectl
2. Google Cloud ((glcoud)[https://cloud.google.com/sdk/docs/install]) CLI
3. GCP Account & Project where you are permitted to create cloud resources
4. Terraform (CLI) 

#### Issues
- None. If you do encounter an issue, please file a GitHub issue.

#### Setup

1. Requires the `gcloud` SDK binary -- [Download here](https://cloud.google.com/sdk/docs/install)

2. Requires the Terraform cli @ Version 1.3.4 or higher -- [Download here](https://developer.hashicorp.com/terraform/downloads)

3. To run this module assumes elevated permissions (Kubernetes Engine Admin) in your GCP account, specifically permissions to create VPC networks, GKE clusters, and Compute nodes. This will not work on accounts using the "free plan" as you cannot use GPU nodes until a billing account is attached and activated. 

4. You will need to enable both the Kubernetes API and the Compute Engine APIs enabled. Click [the GKE tab in the GCP panel](https://console.cloud.google.com/kubernetes) for your project and enable the GKE API, which will also enable the Compute engine API at the same time

5. Ensure you have [GPU Quota](https://cloud.google.com/compute/quotas#gpu_quota) in your desired region/zone. You can [request](GPU Quota) if it is not enabled in a new account. You will need quota for both `GPUS_ALL_REGIONS` and for the specific SKU in the desired region.

## Usage 

#### Running the module
1. `git clone` this repo and `cd` into the directory.
2. Update `terraform.tfvars` by uncommenting `project_id`, `cluster_name`, `region`, and `node_zones`, and filling out the values specific to your project. You can get the `projcet_id` from your GCP console
3. Run `gcloud auth application-default login` to make your Google Credentials availalbe the `terraform` executable
4. Run `terraform init` to fetch the required Terraform provider plugins
5. If your credentials are setup correctly, you should see the proposed changes in GCP by running `terraform plan -out tfplan`.

** Note on IAM Permissions:** you need either `Admin` permissions or `Compute Instance Admin (v1)`, `Kubernetes Engine Admin` and `Compute Network Admin (v1)` to run this module. 

6. If this configuration looks approproate run `terraform apply tfplan`
7. It will take ~5 minutes after the `terraform apply` successful completion message for the GPU operator to get to a running state
8. Connect to the cluster with `kubectl` by running the following two commands after the cluster is created:
```
gcloud components install gke-gcloud-auth-plugin

gcloud container clusters get-credentials <CLUSTER_NAME> --region=<REGION>
```

#### Cleaning up / Deleting resources
1. Run `terraform state rm kubernetes_namespace_v1.gpu-operator` and then run `terraform destroy` to delete all remaining GCP resources created by this module. You should see `Destroy complete!` message after a few minutes.


# Terraform Module Information
## Running as a module

Call the GKE module by adding this to an existing Terraform file:

```hcl
module "nvidia-gke" {
  source     = "git::github.com/NVIDIA/nvidia-terraform-modules/gke"
  project_id = "<your GKE Project ID>"
  region     = "us-west1" # Can be any region
  node_zones = ["us-west1-b"] # Can be any region but ensure your desired machine types/gpus exist
}
```
In a production environment, we suggest pinning to a known tag of this Terraform module
All configurable options for this module are listed below.
If you need additional values added, please open a merge request.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14 |
| <a name="requirement_google"></a> [google](#requirement\_google) | 4.27.0 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | 4.57.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 4.27.0 |
| <a name="provider_google-beta"></a> [google-beta](#provider\_google-beta) | 4.57.0 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | 2.9.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.19.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_network.holoscan-vpc](https://registry.terraform.io/providers/hashicorp/google/4.27.0/docs/resources/compute_network) | resource |
| [google_compute_subnetwork.holoscan-subnet](https://registry.terraform.io/providers/hashicorp/google/4.27.0/docs/resources/compute_subnetwork) | resource |
| [google_container_cluster.holoscan](https://registry.terraform.io/providers/hashicorp/google/4.27.0/docs/resources/container_cluster) | resource |
| [google_container_node_pool.cpu_nodes](https://registry.terraform.io/providers/hashicorp/google/4.27.0/docs/resources/container_node_pool) | resource |
| [google_container_node_pool.gpu_nodes](https://registry.terraform.io/providers/hashicorp/google/4.27.0/docs/resources/container_node_pool) | resource |
| [helm_release.gpu-operator](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_namespace_v1.gpu-operator](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace_v1) | resource |
| [kubernetes_resource_quota_v1.gpu-operator-quota](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/resource_quota_v1) | resource |
| [google-beta_google_container_engine_versions.latest](https://registry.terraform.io/providers/hashicorp/google-beta/4.57.0/docs/data-sources/google_container_engine_versions) | data source |
| [google_client_config.provider](https://registry.terraform.io/providers/hashicorp/google/4.27.0/docs/data-sources/client_config) | data source |
| [google_container_cluster.holoscan-cluster](https://registry.terraform.io/providers/hashicorp/google/4.27.0/docs/data-sources/container_cluster) | data source |
| [google_project.cluster](https://registry.terraform.io/providers/hashicorp/google/4.27.0/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the Kubernetes Cluster to provision | `string` | n/a | yes |
| <a name="input_cpu_instance_type"></a> [cpu\_instance\_type](#input\_cpu\_instance\_type) | Machine Type for CPU node pool | `string` | `"n1-standard-4"` | no |
| <a name="input_cpu_max_node_count"></a> [cpu\_max\_node\_count](#input\_cpu\_max\_node\_count) | Max Number of CPU nodes in CPU nodepool | `string` | `"5"` | no |
| <a name="input_cpu_min_node_count"></a> [cpu\_min\_node\_count](#input\_cpu\_min\_node\_count) | Number of CPU nodes in CPU nodepool | `string` | `"1"` | no |
| <a name="input_disk_size_gb"></a> [disk\_size\_gb](#input\_disk\_size\_gb) | n/a | `string` | `"512"` | no |
| <a name="input_gpu_count"></a> [gpu\_count](#input\_gpu\_count) | Number of GPUs to attach to each node in GPU pool | `string` | `"1"` | no |
| <a name="input_gpu_instance_tags"></a> [gpu\_instance\_tags](#input\_gpu\_instance\_tags) | GPU instance nodes tags | `list(string)` | `[]` | no |
| <a name="input_gpu_instance_type"></a> [gpu\_instance\_type](#input\_gpu\_instance\_type) | Machine Type for GPU node pool | `string` | `"n1-standard-4"` | no |
| <a name="input_gpu_max_node_count"></a> [gpu\_max\_node\_count](#input\_gpu\_max\_node\_count) | Max Number of GPU nodes in GPU nodepool | `string` | `"5"` | no |
| <a name="input_gpu_min_node_count"></a> [gpu\_min\_node\_count](#input\_gpu\_min\_node\_count) | Min number of GPU nodes in GPU nodepool | `string` | `"2"` | no |
| <a name="input_gpu_operator_driver_version"></a> [gpu\_operator\_driver\_version](#input\_gpu\_operator\_driver\_version) | The NVIDIA Driver version deployed with GPU Operator. Defaults to latest available. Not set when `nvaie` is set to true | `string` | `"535.129.03"` | no |
| <a name="input_gpu_operator_namespace"></a> [gpu\_operator\_namespace](#input\_gpu\_operator\_namespace) | The namespace to deploy the NVIDIA GPU operator into | `string` | `"gpu-operator"` | no |
| <a name="input_gpu_operator_version"></a> [gpu\_operator\_version](#input\_gpu\_operator\_version) | Version of the GPU Operator to deploy. Defaults to latest available. Not set when `nvaie` is set to `true` | `string` | `"v23.9.1"` | no |
| <a name="input_gpu_type"></a> [gpu\_type](#input\_gpu\_type) | GPU SKU To attach to Holoscan GPU Node (eg. nvidia-tesla-k80) | `string` | `"nvidia-tesla-v100"` | no |
| <a name="input_min_master_version"></a> [min\_master\_version](#input\_min\_master\_version) | The minimum cluster version of the master. | `string` | `"1.28"` | no |
| <a name="input_network"></a> [network](#input\_network) | Network CIDR for VPC | `string` | `""` | no |
| <a name="input_node_zones"></a> [node\_zones](#input\_node\_zones) | Specify zones to put nodes in (must be in same region defined above) | `list(any)` | n/a | yes |
| <a name="input_num_cpu_nodes"></a> [num\_cpu\_nodes](#input\_num\_cpu\_nodes) | Number of CPU nodes when pool is created | `number` | `1` | no |
| <a name="input_num_gpu_nodes"></a> [num\_gpu\_nodes](#input\_num\_gpu\_nodes) | Number of GPU nodes when pool is created | `number` | `2` | no |
| <a name="input_nvaie"></a> [nvaie](#input\_nvaie) | To use the versions of GPU operator and drivers specified as part of NVIDIA AI Enterprise, set this to true. More information at https://www.nvidia.com/en-us/data-center/products/ai-enterprise | `bool` | `false` | no |
| <a name="input_nvaie_gpu_operator_driver_version"></a> [nvaie\_gpu\_operator\_driver\_version](#input\_nvaie\_gpu\_operator\_driver\_version) | The NVIDIA AI Enterprise version of the NVIDIA driver to be installed with the GPU operator. Overrides `gpu_operator_driver_version` when `nvaie` is set to `true` | `string` | `"535.129.03"` | no |
| <a name="input_nvaie_gpu_operator_version"></a> [nvaie\_gpu\_operator\_version](#input\_nvaie\_gpu\_operator\_version) | The NVIDIA Driver version of GPU Operator. Overrides `gpu_operator_version` when `nvaie` is set to `true` | `string` | `"v23.9.0"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP Project ID for the VPC and K8s Cluster. This module currently does not support projects with a SharedVPC | `any` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The Region resources (VPC, GKE, Compute Nodes) will be created in | `any` | n/a | yes |
| <a name="input_release_channel"></a> [release\_channel](#input\_release\_channel) | Configuration options for the Release channel feature, which provide more control over automatic upgrades of your GKE clusters. When updating this field, GKE imposes specific version requirements | `string` | `"REGULAR"` | no |
| <a name="input_subnetwork"></a> [subnetwork](#input\_subnetwork) | Subnet name used for k8s cluster nodes | `string` | `""` | no |
| <a name="input_use_cpu_spot_instances"></a> [use\_cpu\_spot\_instances](#input\_use\_cpu\_spot\_instances) | Use Spot instance for CPU pool | `bool` | `false` | no |
| <a name="input_use_gpu_spot_instances"></a> [use\_gpu\_spot\_instances](#input\_use\_gpu\_spot\_instances) | Use Spot instance for GPU pool | `bool` | `false` | no |
| <a name="input_vpc_enabled"></a> [vpc\_enabled](#input\_vpc\_enabled) | Variable to control nvidia-kubernetes GKE module VPC creation | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_kubernetes_cluster_endpoint_ip"></a> [kubernetes\_cluster\_endpoint\_ip](#output\_kubernetes\_cluster\_endpoint\_ip) | GKE Cluster IP Endpoint |
| <a name="output_kubernetes_cluster_name"></a> [kubernetes\_cluster\_name](#output\_kubernetes\_cluster\_name) | Holoscan Ready GKE Cluster Name |
| <a name="output_kubernetes_config_file"></a> [kubernetes\_config\_file](#output\_kubernetes\_config\_file) | GKE Cluster IP Endpoint |
| <a name="output_project_id"></a> [project\_id](#output\_project\_id) | GCloud Project ID |
| <a name="output_region"></a> [region](#output\_region) | Region for Holoscan Resources to be created in when using this module |
| <a name="output_subnet_cidr_range"></a> [subnet\_cidr\_range](#output\_subnet\_cidr\_range) | The IPs and CIDRs of the subnets |
| <a name="output_subnet_region"></a> [subnet\_region](#output\_subnet\_region) | The region of the VPC subnet used in this module |
| <a name="output_vpc_project"></a> [vpc\_project](#output\_vpc\_project) | Project of the VPC network (can be different from the project launching Kubernetes resources) |
