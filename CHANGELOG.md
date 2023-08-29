# 0.2.0

### New Features
- [EKS] Add support for selecting NVIDIA Driver Version [PR #2](https://github.com/NVIDIA/nvidia-terraform-modules/pull/2)
- [GKE] Add support for selecting NVIDIA Driver Version [PR #2](https://github.com/NVIDIA/nvidia-terraform-modules/pull/2)
- [EKS] Increment version of GPU operator [PR #2](https://github.com/NVIDIA/nvidia-terraform-modules/pull/2)
- [GKE] Increment version of GPU operator [PR #2](https://github.com/NVIDIA/nvidia-terraform-modules/pull/2)
- [AKS] Add support for deploying cluster in existing resource group [PR #3](https://github.com/NVIDIA/nvidia-terraform-modules/pull/3)

### Bug Fixes
- [EKS] Remove kubeconfig script [PR #4](https://github.com/NVIDIA/nvidia-terraform-modules/pull/4)

### Breaking Changes
n/a

### Other Changes
n/a

### Known Issues
- [EKS] Default VPC `public_subnets` and `private_subnets` values do not maximize reserved `10.0.0.0/16` `cidr_block`. Adjust accordingly to fit your needs.
- [GKE] Permissions to launch module are not explicit [Issue #6](https://github.com/NVIDIA/nvidia-terraform-modules/issues/6)