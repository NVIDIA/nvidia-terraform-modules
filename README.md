# NVIDIA Terraform Kubernetes Modules

## Objective 

NVIDIA Terraform Modules provide a reference architecture for deploying CSP managed Kubernetes clusters equipped with NVIDIA softwares: 

- NVIDIA GPU Operator.
- NVIDIA NIM Operator.

All the components listed below have been tested successfully together.


## Life Cycle 

When NVIDIA Terraform Modules is released, the previous release enters maintenance support and only receives patch release updates. All prior batches enter end-of-life (EOL) and are no longer supported and do not receive patch updates.


|  Release  | Status              |
| :-----: | :--------------:|
| [25.4.0](https://github.com/NVIDIA/cloud-native-stack/releases/tag/v25.4.0)                   | Generally Available |
| [24.11.0](https://github.com/NVIDIA/cloud-native-stack/releases/tag/v24.11.0)                   | Maintenance | 


## Support Matrix

The Kubernetes clusters provisioned by the modules in this repository provide tested and certified versions of Kubernetes, the NVIDIA GPU operator, and NVIDIA NIM Operator.

If your application does not require a specific version of Kubernetes, we recommend using the latest available version. We also recommend you plan to upgrade your version of Kubernetes at least every 6 months.


NVIDIA Terraform Modules 25.4.0 Release:

| TF Modules               | K8s 1.32                                   | K8s 1.31                                   | K8s 1.30 |
| :---------               | :--------                                  | :-------                                   | :------- |
| Platforms                | Amazon EKS <br> Azure AKS <br> Google GKE  | Amazon EKS <br> Azure AKS <br> Google GKE  | Amazon EKS <br> Azure AKS <br> Google GKE  |
| Supported OS             | Ubuntu 24.04 LTS (GKE/EKS) <br> Ubuntu 22.04 LTS (AKS)     | Ubuntu 24.04 LTS (GKE/EKS) <br> Ubuntu 22.04 LTS (AKS)     | Ubuntu 24.04 LTS (GKE/EKS) <br> Ubuntu 22.04 LTS (AKS)     |
| Kernel                   | EKS: 1.7.12 <br> AKS: 5.15.0-1082-azure <br> GKE: 6.8.0-1017-gke | EKS: 1.7.12 <br> AKS: 5.15.0-1082-azure <br> GKE: 6.8.0-1017-gke | EKS: 1.7.12 <br> AKS: 5.15.0-1082-azure <br> GKE: 6.8.0-1017-gke |
| Containerd               | EKS: 1.7.12 <br> AKS: 1.7.26-1 <br> GKE: 1.7.24 | EKS: 1.7.12 <br> AKS: 1.7.26-1 <br> GKE: 1.7.24 | EKS: 1.7.12 <br> AKS: 1.7.26-1 <br> GKE: 1.7.24 |
| CNI                      | CSP dependent                              | CSP dependent                              | CSP dependent                              |
| CSI                      | CSP dependent                              | CSP dependent                              | CSP dependent                              |
| NVIDIA GPU Operator      | 25.3.0                                     | 25.3.0                                     | 25.3.0                                     |
| NVIDIA GPU Operator Operands | NVIDIA Container Toolkit: 1.17.5 <br> NVIDIA Device Plugin: 0.17.1 <br> NVIDIA MIG Manager: 0.12.1 <br> NVIDIA DCGM Exporter: 4.1.1-4.0.4 | NVIDIA Container Toolkit: 1.17.5 <br> NVIDIA Device Plugin: 0.17.1 <br> NVIDIA MIG Manager: 0.12.1 <br> NVIDIA DCGM Exporter: 4.1.1-4.0.4 | NVIDIA Container Toolkit: 1.17.5 <br> NVIDIA Device Plugin: 0.17.1 <br> NVIDIA MIG Manager: 0.12.1 <br> NVIDIA DCGM Exporter: 4.1.1-4.0.4 |
| NVIDIA DataCenter Driver | 570.124.06                                 | 570.124.06                                 | 570.124.06                                 |
| NVIDIA NIM Operator      | 1.0.1                                      | 1.0.1                                      | 1.0.1                                      | 
| Helm                     | 3.17.2                                     | 3.17.2                                     | 3.17.2                                     |


### CSP Managed K8s Services Life Cycle

Each CSP has its own end of life date for the versions of Kubernetes they support. For more information see:

- [Amazon EKS release calendar](https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html#kubernetes-release-calendar)
- [Azure AKS release calendar](https://learn.microsoft.com/en-us/azure/aks/supported-kubernetes-versions?tabs=azure-cli#aks-kubernetes-release-calendar)
- [GCP GKE release calendar](https://cloud.google.com/kubernetes-engine/docs/release-schedule#schedule_for_static_no-channel_versions).


## Getting Started

Infrastructure as code for GPU accelerated managed Kubernetes clusters. These scripts automate the deployment of GPU-Enabled Kubernetes clusters on various cloud service platforms.

Terraform is an open-source infrastructure as code software tool that we will use to automate the deployment of Kubernetes clusters with the required add-ons to enable NVIDIA GPUs. This repository contains Terraform [modules](https://developer.hashicorp.com/terraform/tutorials/modules/module), which are sets of Terraform configuration files ready for deployment. The modules in this repository can be incorporated into existing Terraform-managed infrastructure, or used to set up new infrastructure from scratch. You can learn more about Terraform [here](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/infrastructure-as-code).

You can download Terraform (CLI) [here](https://developer.hashicorp.com/terraform/downloads).

### Usage

Clone the repo
        
  ```
  git clone https://github.com/NVIDIA/nvidia-terraform-modules.git
  ```

#### Provision a GPU enabled Kubernetes Cluster

Select the CSP managed K8s cluster and follow steps indicated in the corresponding page:

- Create an [EKS Cluster](./eks/README.md)
- Create an [AKS Cluster](./aks/README.md)
- Create a [GKE Cluster](./gke/README.md)


### State Management
These modules do not set up state management for the generated Terraform state file, deleting the statefile (`terraform.tfstate`) generated by Terraform could result in cloud resources needing to be manually deleted. We strongly encourage you [configure remote state](https://developer.hashicorp.com/terraform/language/state/remote).

Please see the [Terraform Documentation](https://developer.hashicorp.com/terraform/language/state) for more information.

## Contributing

Pull requests are welcome! Please see our [contribution guidelines](./CONTRIBUTING.md).

## Getting help or Providing feedback

Please open an [issue](https://github.com/NVIDIA/nvidia-terraform-modules/issues) on the GitHub project for any questions. Your feedback is appreciated.


## Useful Links
- [NVIDIA GPU Operator](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/overview.html)
- [NVIDIA NIM Operator](https://docs.nvidia.com/nim-operator/latest/index.html)
- [NVIDIA GPU Cloud (NGC)](https://catalog.ngc.nvidia.com/)
