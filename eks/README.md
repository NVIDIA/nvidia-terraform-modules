# Holoscan Ready Kubernetes (EKS)
This repo provides Terraform configuration to bring up a EKS Kubernetes Cluster with the GPU operator and GPU nodes from scratch.

## Running as a module

Call the EKS module by adding this to an existing Terraform file:

```hcl
module "nvidia-eks" {
  source       = "git::github.com/nvidia/nvidia-terraform-modules/eks" 
  cluster_name = "nvidia-eks"
}
```
In a production environment, we suggest pinning to a known tag of this Terraform module
All configurable options for this module are listed below.
If you need additional values added, please open a pull request.

## Tested on
This module was created and tested on Linux and MacOS.

## Resources Created
- VPC Network for EKS Cluster
- Subnets in VPC for EKS CLuster
- EKS Cluster
- 1x CPU nodepool
- 1x GPU nodepool
- Installs latest version of GPU Operator via Helm
- 1x KMS Key to encrypt cluster secrets

For more details on resources created and their default values, please see the [Terraform Module Inputs](#inputs) section.

## Prerequisites
1. Kubectl 
2. [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
    - You must run `aws-configure` once on your machine to populate the default region present in `~/.aws/config`
3. AWS Account where you have permissions to create a cluster, IAM roles and networking
4. Terraform (CLI)[https://developer.hashicorp.com/terraform/downloads]
5. [JQ](https://stedolan.github.io/jq/download/)
    - The provisioning will fail without this step, as it is used to set up your Kubernetes configuration file file after the cluster is provisioned

#### Issues
- None. If you encounter any, please file a GitHub issue

## Usage

This module assumes that you have a working `terraform` binary and active AWS credentials (admin access or finely scoped permissions with basic EC2, EKS, VPC and IAM creation permissions).

No Terraform Provider is setup for remote state management but can be added.
We strongly encourage you [configure remote state](https://developer.hashicorp.com/terraform/language/state/remote) before running in production.

### CNPack

To create a cluster with everything needed to run the Cloud Native Service Add-on Pack (CNPack), see [the CNPack example](./examples/cnpack/) 

### Steps to run directly from this repository:
1. Clone repo
2. Ensure you have active credentials set with the AWS CLI.
    - You might also run `aws configure` depending on your environment
3. Update `terraform.tfvars` by uncommenting `cluster_name` and `region` and filling out the values specific to your project.

   By default, this module will deploy the cluster into a new VPC. If you want to deploy the cluster into an existing VPC, you must also uncomment and set the `existing_vpc_details` variable.

   Alternatively, you can change any variable names or parameters in any of the following ways:
   - added directly to the `variables.tf`
   - passed in from from the command line with the `-var` flag
   - passed in as environment variables
   - passed in from the command line when prompted 
   
   See Terraform [input variables](https://developer.hashicorp.com/terraform/language/values/variables#assigning-values-to-root-module-variables) for more information.

4. Run `terraform init` to initialize the configured
5. Run `terraform plan` to see what will be applied
6. Run `terraform apply` to apply the code against your AWS environment
7. Connect to the cluster with `kubectl` by running `aws eks update-kubeconfig --name tf-holoscan-cluster --region us-west-2` after the cluster is created
8. Run `terraform destroy` to delete cloud infrastructure provisioned by Terraform

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2.4 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~>4.45.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~>2.19.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.45.0 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | 2.9.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ebs_csi_irsa_role"></a> [ebs\_csi\_irsa\_role](#module\_ebs\_csi\_irsa\_role) | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks | n/a |
| <a name="module_eks"></a> [eks](#module\_eks) | terraform-aws-modules/eks/aws | 18.29.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | 4.0.2 |

## Resources

| Name | Type |
|------|------|
| [helm_release.gpu_operator](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [aws_ami.lookup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_eks_cluster.holoscan](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_instances.nodes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/instances) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_node_security_groups_rules"></a> [additional\_node\_security\_groups\_rules](#input\_additional\_node\_security\_groups\_rules) | List of additional security group rules to add to the node security group created | `any` | `{}` | no |
| <a name="input_additional_security_group_ids"></a> [additional\_security\_group\_ids](#input\_additional\_security\_group\_ids) | list of additional security groups to add to nodes | `list(any)` | `[]` | no |
| <a name="input_additional_user_data"></a> [additional\_user\_data](#input\_additional\_user\_data) | User data that is appended to the user data script after of the EKS bootstrap script. | `string` | `""` | no |
| <a name="input_aws_profile"></a> [aws\_profile](#input\_aws\_profile) | n/a | `string` | `"development"` | no |
| <a name="input_cidr_block"></a> [cidr\_block](#input\_cidr\_block) | CIDR for VPC | `string` | `"10.0.0.0/16"` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | n/a | `string` | n/a | yes |
| <a name="input_cluster_version"></a> [cluster\_version](#input\_cluster\_version) | Version of EKS to install on the control plane (Major and Minor version only, do not include the patch) | `string` | `"1.26"` | no |
| <a name="input_cpu_instance_type"></a> [cpu\_instance\_type](#input\_cpu\_instance\_type) | CPU EC2 worker node instance type | `string` | `"t2.xlarge"` | no |
| <a name="input_cpu_node_pool_additional_user_data"></a> [cpu\_node\_pool\_additional\_user\_data](#input\_cpu\_node\_pool\_additional\_user\_data) | User data that is appended to the user data script after of the EKS bootstrap script on EKS-managed GPU node pool. | `string` | `""` | no |
| <a name="input_cpu_node_pool_delete_on_termination"></a> [cpu\_node\_pool\_delete\_on\_termination](#input\_cpu\_node\_pool\_delete\_on\_termination) | Delete the VM nodes root filesystem on each node of the instance type. This is set to true by default, but can be changed when desired when using the 'local-storage provisioner' and are keeping important application data on the nodes | `bool` | `true` | no |
| <a name="input_cpu_node_pool_root_disk_size_gb"></a> [cpu\_node\_pool\_root\_disk\_size\_gb](#input\_cpu\_node\_pool\_root\_disk\_size\_gb) | The size of the root disk on all GPU nodes in the EKS-managed GPU-only Node Pool. This is primarily for container image storage on the node | `number` | `512` | no |
| <a name="input_cpu_node_pool_root_volume_type"></a> [cpu\_node\_pool\_root\_volume\_type](#input\_cpu\_node\_pool\_root\_volume\_type) | The type of disk to use for the GPU node pool root disk (eg. gp2, gp3). Note, this is different from the type of disk used by applications via EKS Storage classes/PVs & PVCs | `string` | `"gp2"` | no |
| <a name="input_desired_count_cpu_nodes"></a> [desired\_count\_cpu\_nodes](#input\_desired\_count\_cpu\_nodes) | Minimum number of CPU nodes in the Autoscaling Group | `string` | `"1"` | no |
| <a name="input_desired_count_gpu_nodes"></a> [desired\_count\_gpu\_nodes](#input\_desired\_count\_gpu\_nodes) | Minimum number of GPU nodes in the Autoscaling Group | `string` | `"2"` | no |
| <a name="input_enable_dns_hostnames"></a> [enable\_dns\_hostnames](#input\_enable\_dns\_hostnames) | Whether or not the Default VPC has DNS hostname support | `bool` | `true` | no |
| <a name="input_enable_dns_support"></a> [enable\_dns\_support](#input\_enable\_dns\_support) | Whether or not the Default VPC has DNS support | `bool` | `true` | no |
| <a name="input_enable_nat_gateway"></a> [enable\_nat\_gateway](#input\_enable\_nat\_gateway) | Should be true if you want to provision NAT Gateways for each of your private networks | `bool` | `true` | no |
| <a name="input_existing_vpc_details"></a> [existing\_vpc\_details](#input\_existing\_vpc\_details) | Variables used for re-using existing VPC for vpc\_id & subnet\_id | <pre>object({<br>    vpc_id     = string<br>    subnet_ids = list(string)<br>  })</pre> | `null` | no |
| <a name="input_gpu_ami_id"></a> [gpu\_ami\_id](#input\_gpu\_ami\_id) | AMI ID of the EKS Ubuntu Image cooresponding to the region and version of the cluser. Not required as we do a lookup for this image | `string` | `""` | no |
| <a name="input_gpu_instance_type"></a> [gpu\_instance\_type](#input\_gpu\_instance\_type) | GPU EC2 worker node instance type | `string` | `"p3.2xlarge"` | no |
| <a name="input_gpu_node_pool_additional_user_data"></a> [gpu\_node\_pool\_additional\_user\_data](#input\_gpu\_node\_pool\_additional\_user\_data) | User data that is appended to the user data script after of the EKS bootstrap script on EKS-managed GPU node pool. | `string` | `""` | no |
| <a name="input_gpu_node_pool_delete_on_termination"></a> [gpu\_node\_pool\_delete\_on\_termination](#input\_gpu\_node\_pool\_delete\_on\_termination) | Delete the VM nodes root filesystem on each node of the instance type. This is set to true by default, but can be changed when desired when using the 'local-storage provisioner' and are keeping important application data on the nodes | `bool` | `true` | no |
| <a name="input_gpu_node_pool_root_disk_size_gb"></a> [gpu\_node\_pool\_root\_disk\_size\_gb](#input\_gpu\_node\_pool\_root\_disk\_size\_gb) | The size of the root disk on all GPU nodes in the EKS-managed GPU-only Node Pool. This is primarily for container image storage on the node | `number` | `512` | no |
| <a name="input_gpu_node_pool_root_volume_type"></a> [gpu\_node\_pool\_root\_volume\_type](#input\_gpu\_node\_pool\_root\_volume\_type) | The type of disk to use for the GPU node pool root disk (eg. gp2, gp3). Note, this is different from the type of disk used by applications via EKS Storage classes/PVs & PVCs | `string` | `"gp2"` | no |
| <a name="input_gpu_operator_driver_version"></a> [gpu\_operator\_driver\_version](#input\_gpu\_operator\_driver\_version) | The NVIDIA Driver version of GPU Operator | `string` | `"535.54.03"` | no |
| <a name="input_gpu_operator_namespace"></a> [gpu\_operator\_namespace](#input\_gpu\_operator\_namespace) | The namespace for the GPU operator deployment | `string` | `"gpu-operator"` | no |
| <a name="input_gpu_operator_version"></a> [gpu\_operator\_version](#input\_gpu\_operator\_version) | The version of the GPU operator | `string` | `"v23.3.2"` | no |
| <a name="input_max_cpu_nodes"></a> [max\_cpu\_nodes](#input\_max\_cpu\_nodes) | Maximum number of CPU nodes in the Autoscaling Group | `string` | `"2"` | no |
| <a name="input_max_gpu_nodes"></a> [max\_gpu\_nodes](#input\_max\_gpu\_nodes) | Maximum number of GPU nodes in the Autoscaling Group | `string` | `"5"` | no |
| <a name="input_min_cpu_nodes"></a> [min\_cpu\_nodes](#input\_min\_cpu\_nodes) | Minimum number of CPU nodes in the Autoscaling Group | `string` | `"0"` | no |
| <a name="input_min_gpu_nodes"></a> [min\_gpu\_nodes](#input\_min\_gpu\_nodes) | Minimum number of GPU nodes in the Autoscaling Group | `string` | `"2"` | no |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | List of subnet ranges for the Holoscan VPC | `list(any)` | <pre>[<br>  "10.0.1.0/24",<br>  "10.0.2.0/24",<br>  "10.0.3.0/24"<br>]</pre> | no |
| <a name="input_public_subnets"></a> [public\_subnets](#input\_public\_subnets) | List of subnet ranges for the Holoscan VPC | `list(any)` | <pre>[<br>  "10.0.4.0/24",<br>  "10.0.5.0/24",<br>  "10.0.6.0/24"<br>]</pre> | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region to provision the Holoscan Compliant Kubernetes Cluster | `string` | `"us-west-2"` | no |
| <a name="input_single_nat_gateway"></a> [single\_nat\_gateway](#input\_single\_nat\_gateway) | Should be true if you want to provision a single shared NAT Gateway across all of your private networks | `bool` | `false` | no |
| <a name="input_ssh_key"></a> [ssh\_key](#input\_ssh\_key) | n/a | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_ca_certificate"></a> [cluster\_ca\_certificate](#output\_cluster\_ca\_certificate) | n/a |
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | n/a |
| <a name="output_cpu_node_role_name"></a> [cpu\_node\_role\_name](#output\_cpu\_node\_role\_name) | IAM Node Role Bane for CPU node pools |
| <a name="output_gpu_node_role_name"></a> [gpu\_node\_role\_name](#output\_gpu\_node\_role\_name) | IAM Node Role Name for GPU node pools |
| <a name="output_kube_exec_api_version"></a> [kube\_exec\_api\_version](#output\_kube\_exec\_api\_version) | n/a |
| <a name="output_kube_exec_args"></a> [kube\_exec\_args](#output\_kube\_exec\_args) | n/a |
| <a name="output_kube_exec_command"></a> [kube\_exec\_command](#output\_kube\_exec\_command) | n/a |
| <a name="output_nodes"></a> [nodes](#output\_nodes) | n/a |
| <a name="output_oidc_endpoint"></a> [oidc\_endpoint](#output\_oidc\_endpoint) | n/a |
| <a name="output_private_subnet_ids"></a> [private\_subnet\_ids](#output\_private\_subnet\_ids) | n/a |
| <a name="output_public_subnet_ids"></a> [public\_subnet\_ids](#output\_public\_subnet\_ids) | n/a |
