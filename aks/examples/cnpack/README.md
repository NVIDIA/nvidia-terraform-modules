# CNPack Example Deployment for Azure AKS

### Resources Created
- All resources from the root module (AKS Cluster)
- Azure Log Analytics Workspace (For Ingesting Fluentbit Logs)
- Azure Resource Group for Fluentbit
- nvidia-monitoring namespace and secret containing the `log_analytics_workspace_primary_shared_key` for CNPack
- Role assignment for AKS cluster to publish metrics to the metrics endpoint
- Azure Monitor Workspace (For Ingesting Prometheus Logs)


### Requirements

1. The Azure user should have permissions to create a Kubernetes Cluster, attach Active Directory roles to it, and create Azure Log Analytics and Monitoring Workspaces.

2. Requires [CNPack](https://docs.nvidia.com/ai-enterprise/deployment-guide-cloud-native-service-add-on-pack/0.1.0/cns-deployment.html) binary, AWS CLI, Kubectl and [kubelogin](https://github.com/Azure/kubelogin) 


## To use:

1. Update the `terraform.tfvars` file to not be prompted for variable input
    - Add `cluster_name`
    - Add the IDs of the members or groups who should have cluster access to the variable `admin_group_object_ids`. The GUID input can be retrieved in the Azure portal by searching for the desired user or group
    - Add `fluentbit_workspace_name`. This will create Azure Log Analytics Workspace with the specified name.
    - Add `prometheus_name`. This will create Azure Monitor Workspace with the specified name.

2. Run `terraform plan` and validate that the output is correct

3. Run `terraform apply`

4. The `outputs` of this module can be used immediately within the configuration file of CNPack

**Note**
The `log_analytics_workspace_primary_shared_key` used for Fluentbit is a sensitive variable and should be protected like a password
As a result, the value will not show in the terminal as a usual output.
If it is needed to get the value of `log_analytics_workspace_primary_shared_key`, run `grep -A 2 "log_analytics_workspace_primary_shared_key" terraform.tfstate`, however the shared key is saved as a Kubernetes secret which CNPack will automatically read from, so it is not required to view the value of this output.


## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | ~>1.4.0 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | ~> 2.15.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azapi"></a> [azapi](#provider\_azapi) | 1.4.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.48.0 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_holoscan-ready-aks"></a> [holoscan-ready-aks](#module\_holoscan-ready-aks) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [azapi_resource.prometheus-cnpack](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azurerm_log_analytics_workspace.cnpack-fluentbit-workspace](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |
| [azurerm_role_assignment.cnpack-prometheus-role](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [null_resource.create-fluentbit-secret](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [azapi_resource.prometheus-cnpack](https://registry.terraform.io/providers/Azure/azapi/latest/docs/data-sources/resource) | data source |
| [azurerm_kubernetes_cluster.holoscancluster](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/kubernetes_cluster) | data source |
| [azurerm_log_analytics_workspace.fluent](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/log_analytics_workspace) | data source |
| [azurerm_resource_group.prometheus](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_user_assigned_identity.cnpack-cluster-managed-id](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/user_assigned_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_group_object_ids"></a> [admin\_group\_object\_ids](#input\_admin\_group\_object\_ids) | (Required) A list of Object IDs (GUIDs) of Azure Active Directory Groups which should have Owner Role on the Cluster. <br>  This is not the email address of the group, the GUID can be found in the Azure panel by searching for the AD Group<br>  NOTE: You will need Azure "Owner" role (not "Contributor") to attach an AD role to the Kubernetes cluster. | `list(any)` | n/a | yes |
| <a name="input_az_monitor_user_managed_id"></a> [az\_monitor\_user\_managed\_id](#input\_az\_monitor\_user\_managed\_id) | The user managed identity to *create* for use with the Azure monitor-- at this time this does not accept existing user or system managed identity | `string` | `"tf-holoscan-identity"` | no |
| <a name="input_azure_log_analytics_retention_in_days"></a> [azure\_log\_analytics\_retention\_in\_days](#input\_azure\_log\_analytics\_retention\_in\_days) | The workspace data retention in days. Possible values are either 7 (Free Tier only) or range between 30 and 730 | `number` | `30` | no |
| <a name="input_azure_log_analytics_sku"></a> [azure\_log\_analytics\_sku](#input\_azure\_log\_analytics\_sku) | Specifies the SKU of the Log Analytics Workspace. Possible values are Free, PerNode, Premium, Standard, Standalone, Unlimited, CapacityReservation, and PerGB2018. Defaults to PerGB2018 | `string` | `"PerGB2018"` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the cluster | `string` | n/a | yes |
| <a name="input_fluentbit_enabled"></a> [fluentbit\_enabled](#input\_fluentbit\_enabled) | Set to true to enable, false to disable | `bool` | `true` | no |
| <a name="input_fluentbit_workspace_name"></a> [fluentbit\_workspace\_name](#input\_fluentbit\_workspace\_name) | Name of the Azure Log Workspace for Fluentbit to be created | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The region to create resources in. This can be filed out in the terraform.tfvars file in this directory | `any` | n/a | yes |
| <a name="input_prometheus_name"></a> [prometheus\_name](#input\_prometheus\_name) | The name of the Azure Monitor Workspace for Prometheus | `string` | n/a | yes |
| <a name="input_prometheus_resource_group_name"></a> [prometheus\_resource\_group\_name](#input\_prometheus\_resource\_group\_name) | Name of the Prometheus resource group | `string` | `"prometheus-rg"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_managed-client-id"></a> [cluster\_managed-client-id](#output\_cluster\_managed-client-id) | Output info on managed ID for use with CNPack |
| <a name="output_fluentbit-secret-name"></a> [fluentbit-secret-name](#output\_fluentbit-secret-name) | Output the name of the created secret for use with CNPack |
| <a name="output_fluentbit-secret-namespace"></a> [fluentbit-secret-namespace](#output\_fluentbit-secret-namespace) | Output the namespace of the created secret for use with CNPack |
| <a name="output_prometheus-query-url"></a> [prometheus-query-url](#output\_prometheus-query-url) | Output the Ingestion URL of Prometheus for use with CNPack |