# NVIDIA Terraform Kubernetes Modules

Infrastructure as code for GPU accelerated managed Kubernetes clusters. These scripts automate the deployment of GPU-Enabled Kubernetes clusters on various cloud service platforms.

## Getting Started With Terraform

Terraform is an open-source infrastructure as code software tool that we will use to automate the deployment of Kubernetes clusters with the required add-ons to enable NVIDIA GPUs. This repository contains Terraform [modules](https://developer.hashicorp.com/terraform/tutorials/modules/module), which are sets of Terraform configuration files ready for deployment. The modules in this repository can be incorporated into existing Terraform-managed infrastructure, or used to set up new infrastructure from scratch. You can learn more about Terraform [here](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/infrastructure-as-code).

You can download Terraform (CLI) [here](https://developer.hashicorp.com/terraform/downloads).

## Support Matrix

NVIDIA offers support for Kubernetes through [NVIDIA AI Enterprise](https://www.nvidia.com/en-us/data-center/products/ai-enterprise/). Refer to the [product support matrix](https://docs.nvidia.com/ai-enterprise/latest/product-support-matrix/index.html#nvaie-supported-cloud-services) for supported managed Kubernetes platforms.

The Kubernetes clusters provisioned by the modules in this repository provide tested and certified versions of Kubernetes, the NVIDIA GPU operator, and the NVIDIA Driver.

If your application does not require a specific version of Kubernetes, we recommend using the latest available version. We also recommend you plan to upgrade your version of Kubernetes at least every 6 months.

Each CSP has its own end of life date for the versions of Kubernetes they support. For more information see: 

- [Amazon EKS release calendar](https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html#kubernetes-release-calendar)
- [Azure AKS release calendar](https://learn.microsoft.com/en-us/azure/aks/supported-kubernetes-versions?tabs=azure-cli#aks-kubernetes-release-calendar) 
- [GCP GKE release calendar](https://cloud.google.com/kubernetes-engine/docs/release-schedule#schedule_for_static_no-channel_versions).

| Version | Release Date  | Kubernetes Versions                            | NVIDIA GPU Operator    | NVIDIA Data Center Driver* | End of Life |
| :---    |    :---       | :---                                           | :---                   | :---                      | :--- |
| 0.7.0     | April 2024 | EKS -  1.29 <br> GKE - 1.29 <br> AKS - 1.29 | 23.9.2 (Default); 23.9.2 (NV AI E)                 | 550.54.15  (EKS & GKE Default); 550.54.15 (NV AI E version for GKE & EKS)    | EKS - Mar 2025 <br> GKE - Mar 2025  <br> AKS - Not Specified |
| 0.6.0     | January 2024 | EKS -  1.28 <br> GKE - 1.28 <br> AKS - 1.28 | 23.9.1 (Default); 23.9.0 (NV AI E)                 | 535.129.03  (EKS & GKE Default); 535.129.03 (NV AI E version for GKE & EKS)    | EKS - Nov 2024 <br> GKE - Nov 2024  <br> AKS - Nov 2024 |
| 0.5.0     | November 2023 | EKS -  1.27 <br> GKE - 1.27 <br> AKS - 1.27 | 23.6.1 (Default); 23.3.2 (NV AI E)                 | 535.104.05  (EKS & GKE Default); 525.125.06 (NV AI E version for GKE & EKS)    | EKS - July 2024 <br> GKE - August 2024  <br> AKS - July 2024 |
| 0.4.0     | October 2023 | EKS -  1.27 <br> GKE - 1.27 <br> AKS - 1.27 | 23.6.1 (Default); 23.3.2 (NV AI E)                 | 535.104.05  (EKS & GKE Default); 525.125.06 (NV AI E version for GKE & EKS)    | EKS - July 2024 <br> GKE - August 2024  <br> AKS - July 2024 |
| 0.3.0     | September 2023 | EKS -  1.26 <br> GKE - 1.26 <br> AKS - 1.26 | 23.6.1 (Default); 23.3.2 (NV AI E)                 | 535.54.03  (EKS & GKE Default); 525.125.06 (NV AI E version for GKE & EKS)    | EKS - June 2024 <br> GKE - June 2024  <br> AKS - March 2024 |
| 0.2.0     | August 2023    | EKS -  1.26 <br> GKE - 1.26 <br> AKS - 1.26 | 23.3.2 | 535.54.03  (EKS & GKE) | EKS - June 2024 <br> GKE - June 2024  <br> AKS - March 2024 |
| 0.1.0     | June 2023      | EKS -  1.26 <br> GKE - 1.26 <br> AKS - 1.26 | 23.3.2 | 525.105.17             | EKS - June 2024 <br> GKE - June 2024  <br> AKS - March 2024 |

* On AKS, the driver comes pre-installed on the host and the version is not known in advance.

## Usage


#### Provision a GPU enabled Kubernetes Cluster
- Create an [EKS Cluster](./eks/README.md)
- Create an [AKS Cluster](./aks/README.md)
- Create a [GKE Cluster](./gke/README.md)


### Creating an EKS Cluster
Call the EKS module by adding this to an existing Terraform file:

```hcl
module "nvidia-eks" {
  source       = "git::github.com/nvidia/nvidia-terraform-modules/eks" 
  cluster_name = "nvidia-eks"
}
```
See the [EKS README](./eks/README.md) for all available configuration options.


### Creating an AKS Cluster

Call the AKS module by adding this to an existing Terraform file:


```hcl
module "nvidia-aks" {
  source                 = "git::github.com/NVIDIA/nvidia-terraform-modules/aks" 
  cluster_name           = "nvidia-aks-cluster"
  admin_group_object_ids = [] # See description of this value in the AKS Readme
  location               = "us-west1"
}
```
See the [AKS README](./aks/README.md) for all available configuration options.

### Creating a GKE Cluster

Call the GKE module by adding this to an existing Terraform file:

```hcl
module "nvidia-gke" {
  source       = "git::github.com/NVIDIA/nvidia-terraform-modules/gke" 
  cluster_name =  "nvidia-gke-cluster"
  project_id   =  "your-gcp-project-id"
  region       =  "us-west1"     
  node_zones   =  ["us-west1-a"]
}
```
See the [GKE README](./gke/README.md) for all available configuration options.

### Cloud Native Service Add On Pack (CNPack)
In each subdirectory, there is a Terraform module to provision the Kubernetes cluster and any additional prerequisite cloud infrastructure to launch CNPack. 
See [CNPack on EKS](./eks/examples/cnpack/), [CNPack on GKE](./gke/examples/cnpack/), and [CNPack on AKS](./aks/examples/cnpack/) for more information and the sample CNPack configuration file.

More information on CNPack can be found on the [NVIDIA AI Enterprise Documentation](https://docs.nvidia.com/ai-enterprise/deployment-guide-cloud-native-service-add-on-pack/0.1.0/cns-deployment.html)


### State Management
These modules do not set up state management for the generated Terraform state file, deleting the statefile (`terraform.tfstate`) generated by Terraform could result in cloud resources needing to be manually deleted. We strongly encourage you [configure remote state](https://developer.hashicorp.com/terraform/language/state/remote).
Please see the [Terraform Documentation](https://developer.hashicorp.com/terraform/language/state) for more information.

## Contributing

Pull requests are welcome! Please see our [contribution guidelines](./CONTRIBUTING.md).

## Getting help or Providing feedback

Please open an [issue](https://github.com/NVIDIA/nvidia-terraform-modules/issues) on the GitHub project for any questions. Your feedback is appreciated.


## Useful Links
- [NVIDIA AI Enterprise](https://www.nvidia.com/en-us/data-center/products/ai-enterprise/)
- [NVIDIA GPU Operator](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/overview.html)
- [NVIDIA GPU Cloud (NGC)](https://catalog.ngc.nvidia.com/)
