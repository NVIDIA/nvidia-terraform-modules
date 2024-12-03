#  NVIDIA AKS cluster

## Tested on
This module was created and tested on Linux and MacOS.

## Resources Created
- Azure Resource Group
- AKS Cluster
- 1x CPU nodepool (defaults to 1x CPU node -- Standard_D16_v5)
- 2x GPU nodepool (defaults to 1x T4 -- Standard_NC6s_v3)
- Installs Latest version of GPU Operator

## Prerequisites
1. Kubectl
2. [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
3. Azure Account & Subscription where you are permitted to create cloud resources
4. Terraform (CLI)
5. [Azure Kubelogin](https://github.com/Azure/kubelogin#setup)

## Usage

This module assumes that you have a working `terraform` binary and active Azure credentials.

No Terraform Provider is setup for remote state management but can be added.
We strongly encourage you [configure remote state](https://developer.hashicorp.com/terraform/language/state/remote) before running in production.

1. Clone the repo
        
    ```
    git clone https://github.com/NVIDIA/nvidia-terraform-modules.git

    cd aks
    ```

2. Logging in to Azure via the CLI
    - Run the below command , this will authenticate you to your Azure account
        
    ```
    az login
    ```

3. Update `terraform.tfvars` file to customize a parameter from its default value, please uncomment the line and change the content

    - update `cluster_name`, if needed
    - update `location`, if needed
    - Add the IDs of the members or groups who should have cluster access to the variable `admin_group_object_ids`. 

        The GUID input can be retrieved in the Azure portal by searching for the desired user or group, for more info please refer [Find Object Id](https://learn.microsoft.com/en-us/partner-center/marketplace/find-tenant-object-id)

    - Set `true` for `install_nim_operator`, if you want to install NIM Operator

        ```
        admin_group_object_ids       = ["xxxxxxx-xxx-xxxx-xxxx-xxxxxxxxxx"]
        cluster_name                 = "aks-cluster"
        # cpu_machine_type             = "Standard_D16_v5"
        # cpu_node_pool_count          = 1
        # cpu_node_pool_disk_size      = 100
        # cpu_node_pool_max_count      = 5
        # cpu_node_pool_min_count      = 1
        # cpu_os_sku                   = "Ubuntu"
        # existing_resource_group_name = ""
        # gpu_machine_type             = "Standard_NC6s_v3"
        # gpu_node_pool_count          = 2
        # gpu_node_pool_disk_size      = 100
        # gpu_node_pool_max_count      = 5
        # gpu_node_pool_min_count      = 1 
        install_gpu_operator         = "true"
        # gpu_operator_namespace       = "gpu-operator"
        # gpu_operator_version         = "v24.9.0"
        # gpu_operator_driver_version  = "550.127.05"
        # install_nim_operator         = "false"
        # nim_operator_version         = "v1.0.0"
        # nim_operator_namespace       = "nim-operator"
        # gpu_os_sku                   = "Ubuntu"
        # kubernetes_version           = "1.30"
        location                     = "westus2"
        ```

4. Initialize the module with below command 
        
    ```
    terraform init
    ```

5. Run the below command to view the proposed changes

    ```
    terraform plan -out tfplan
    ```

6. Run the below command to apply the configuration

    ```
    terraform apply tfplan
    ```

7. Once cluster is created run the below command with aks cluster name and resource group name to get kubeconfig so you are able to run `kubectl` commands

    ```
    az aks get-credentials --resource-group aks-cluster-rg --name aks-cluster
    ```

#### Cleaning up / Deleting resources

1. Run the beloe commands to delete all remaining Azure resources created by this module. You should see `Destroy complete!` message after a few minutes.
        
    ```
    terraform state rm kubernetes_namespace_v1.gpu-operator

    terraform state rm kubernetes_namespace_v1.nim-operator
    ```

    ```
    terraform destroy --auto-approve
    ```
    
## Running as a module

Call the AKS module by adding this to an existing Terraform file:

```hcl
module "nvidia-aks" {
  source                 = "git::github.com/NVIDIA/nvidia-terraform-modules/aks" 
  cluster_name           = "nvidia-aks"
  admin_group_object_ids = [] # See below for the value of this variable
}
```
All configurable options for this module are listed below.
If you need additional values added, please open a pull request.        ```

## Issues
- None. If you do encounter an issue, please file a GitHub issue.

## Troubleshooting
-  ### Quota Errors
    New Azure accounts which have not turned on VMs or GPU VMs in any region will need to request quota in that region. 
    During installation, if you see a quota-related error, click the link in the error message to be redirected to the Azure console with a prepopulated quota request. Re-run `terraform apply` once the quota request is complete. This will take ~5m per quota request

- ### Azure Cloudshell Errors
  When using Azure Cloudshell during installation, if you see a `MSI` or `Bad Request(400)` error, it is [known issue](https://github.com/Azure/azure-cli/issues/11749) with Azure Cloushell. 
  There are 2 workarounds:
  - Use Azure CLI on a local machine
  -  In Cloud Shell, run `az login` and re-run `terraform apply`


## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.4 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~>3.48.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~>2.19.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~>3.48.0 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | n/a |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | ~>2.19.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_kubernetes_cluster.aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster) | resource |
| [azurerm_kubernetes_cluster_node_pool.aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster_node_pool) | resource |
| [azurerm_resource_group.aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [helm_release.gpu-operator](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.nim_operator](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_namespace_v1.gpu-operator](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace_v1) | resource |
| [kubernetes_namespace_v1.nim-operator](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace_v1) | resource |
| [azurerm_kubernetes_cluster.akscluster](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/kubernetes_cluster) | data source |
| [azurerm_resource_group.existing](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_group_object_ids"></a> [admin\_group\_object\_ids](#input\_admin\_group\_object\_ids) | (Required) A list of Object IDs (GUIDs) of Azure Active Directory Groups which should have Owner Role on the Cluster. <br>  This is not the email address of the group, the GUID can be found in the Azure panel by searching for the AD Group<br>  NOTE: You will need Azure "Owner" role (not "Contributor") to attach an AD role to the Kubernetes cluster. | `list(any)` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the AKS Cluster to be created | `string` | `"aks-cluster"` | no |
| <a name="input_cpu_machine_type"></a> [cpu\_machine\_type](#input\_cpu\_machine\_type) | Machine instance type of the AKS CPU node pool | `string` | `"Standard_D16_v5"` | no |
| <a name="input_cpu_node_pool_count"></a> [cpu\_node\_pool\_count](#input\_cpu\_node\_pool\_count) | Count of nodes in Default GPU pool | `number` | `1` | no |
| <a name="input_cpu_node_pool_disk_size"></a> [cpu\_node\_pool\_disk\_size](#input\_cpu\_node\_pool\_disk\_size) | Disk size in GB of nodes in the Default GPU pool | `number` | `100` | no |
| <a name="input_cpu_node_pool_max_count"></a> [cpu\_node\_pool\_max\_count](#input\_cpu\_node\_pool\_max\_count) | Max count of nodes in Default CPU pool | `number` | `5` | no |
| <a name="input_cpu_node_pool_min_count"></a> [cpu\_node\_pool\_min\_count](#input\_cpu\_node\_pool\_min\_count) | Min ount of number of nodes in Default CPU pool | `number` | `1` | no |
| <a name="input_cpu_os_sku"></a> [cpu\_os\_sku](#input\_cpu\_os\_sku) | Specifies the OS SKU used by the agent pool. Possible values include: Ubuntu, CBLMariner, Mariner, Windows2019, Windows2022 | `string` | `"Ubuntu"` | no |
| <a name="input_existing_resource_group_name"></a> [existing\_resource\_group\_name](#input\_existing\_resource\_group\_name) | The name of an existing resource group the Kubernetes cluster should be deployed into. Defaults to the name of the cluster + `-rg` if none is specified | `string` | `null` | no |
| <a name="input_gpu_machine_type"></a> [gpu\_machine\_type](#input\_gpu\_machine\_type) | Machine instance type of the AKS GPU node pool | `string` | `"Standard_NC6s_v3"` | no |
| <a name="input_gpu_node_pool_count"></a> [gpu\_node\_pool\_count](#input\_gpu\_node\_pool\_count) | Count of nodes in Default GPU pool | `number` | `2` | no |
| <a name="input_gpu_node_pool_disk_size"></a> [gpu\_node\_pool\_disk\_size](#input\_gpu\_node\_pool\_disk\_size) | Disk size in GB of nodes in the Default GPU pool | `number` | `100` | no |
| <a name="input_gpu_node_pool_max_count"></a> [gpu\_node\_pool\_max\_count](#input\_gpu\_node\_pool\_max\_count) | Max count of nodes in Default GPU pool | `number` | `5` | no |
| <a name="input_gpu_node_pool_min_count"></a> [gpu\_node\_pool\_min\_count](#input\_gpu\_node\_pool\_min\_count) | Min count of number of nodes in Default GPU pool | `number` | `2` | no |
| <a name="input_gpu_operator_driver_version"></a> [gpu\_operator\_driver\_version](#input\_gpu\_operator\_driver\_version) | The NVIDIA Driver version deployed with GPU Operator. Defaults to latest available. | `string` | `"550.127.05"` | no |
| <a name="input_gpu_operator_namespace"></a> [gpu\_operator\_namespace](#input\_gpu\_operator\_namespace) | The namespace to deploy the NVIDIA GPU operator into | `string` | `"gpu-operator"` | no |
| <a name="input_gpu_operator_version"></a> [gpu\_operator\_version](#input\_gpu\_operator\_version) | Version of the GPU operator to be installed | `string` | `"v24.9.0"` | no |
| <a name="input_gpu_os_sku"></a> [gpu\_os\_sku](#input\_gpu\_os\_sku) | Specifies the OS SKU used by the agent pool. Possible values include: Ubuntu, CBLMariner, Mariner, Windows2019, Windows2022 | `string` | `"Ubuntu"` | no |
| <a name="input_install_gpu_operator"></a> [install\_gpu\_operator](#input\_install\_gpu\_operator) | Whether to Install GPU Operator. Defaults to false available. | `string` | `"true"` | no |
| <a name="input_install_nim_operator"></a> [install\_nim\_operator](#input\_install\_nim\_operator) | Whether to Install NIM Operator. Defaults to false available. | `string` | `"false"` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | Version of Kubernetes to turn on. Run 'az aks get-versions --location <location> --output table' to view all available versions | `string` | `"1.30"` | no |
| <a name="input_location"></a> [location](#input\_location) | The region to create resources in | `any` | n/a | yes |
| <a name="input_nim_operator_namespace"></a> [nim\_operator\_namespace](#input\_nim\_operator\_namespace) | The namespace for the GPU operator deployment | `string` | `"nim-operator"` | no |
| <a name="input_nim_operator_version"></a> [nim\_operator\_version](#input\_nim\_operator\_version) | Version of the GPU Operator to deploy. Defaults to latest available. | `string` | `"v1.0.0"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_client_certificate"></a> [client\_certificate](#output\_client\_certificate) | n/a |
| <a name="output_kube_config"></a> [kube\_config](#output\_kube\_config) | n/a |
| <a name="output_kubernetes_cluster_name"></a> [kubernetes\_cluster\_name](#output\_kubernetes\_cluster\_name) | n/a |
| <a name="output_location"></a> [location](#output\_location) | n/a |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | n/a |