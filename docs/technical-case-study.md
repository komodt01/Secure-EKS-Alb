# Technical Case Study – Secure Amazon EKS Architecture

## Technical Objective

The objective of this project was to establish an Amazon EKS infrastructure foundation that separates public and private network tiers and uses workload-specific AWS identity for AWS Load Balancer Controller integration.

Terraform was used to define the AWS infrastructure and IAM configuration.

## Network Architecture

The VPC uses the `10.0.0.0/16` CIDR range and spans two Availability Zones in `us-east-1`.

Four subnets are defined:

- Public: `10.0.1.0/24`
- Public: `10.0.2.0/24`
- Private: `10.0.3.0/24`
- Private: `10.0.4.0/24`

The public subnets are tagged for Kubernetes ELB discovery, while the private subnets are tagged for internal ELB discovery.

NAT gateway functionality is enabled to support outbound connectivity from resources operating in the private subnet tier.

## Amazon EKS

Terraform provisions an Amazon EKS cluster running Kubernetes 1.29.

The EKS managed node group is explicitly assigned to the private subnets and configured with:

- Minimum nodes: 1
- Desired nodes: 2
- Maximum nodes: 3
- Instance type: `t3.medium`

The EKS API endpoint is configured for public access. This is distinct from the worker-node placement: the worker nodes reside in private subnets even though the Kubernetes control-plane API endpoint is publicly accessible.

## IAM Roles for Service Accounts

IRSA is enabled for the EKS cluster.

Terraform creates an IAM role intended for the AWS Load Balancer Controller and establishes a federated trust relationship with the EKS OIDC provider.

The trust policy restricts role assumption to:

`system:serviceaccount:kube-system:aws-load-balancer-controller`

The audience condition is restricted to:

`sts.amazonaws.com`

This associates the AWS IAM role with the intended Kubernetes service account rather than granting the controller AWS permissions through the worker-node role.

## AWS Load Balancer Controller Permissions

The repository contains a separate IAM policy document for AWS Load Balancer Controller operations.

The policy includes permissions associated with services such as:

- Elastic Load Balancing
- EC2 networking and security groups
- AWS Certificate Manager
- AWS WAF
- AWS Shield
- IAM service-linked roles

Terraform attaches this policy to the IAM role created for the controller.

The controller installation itself is separate from the Terraform-managed infrastructure in this repository.

## Validation

Operational validation commands are documented separately in `docs/validation.md`.

These include:

- Updating the local kubeconfig for the EKS cluster.
- Checking registered Kubernetes worker nodes.
- Checking for the AWS Load Balancer Controller deployment in the `kube-system` namespace.

These commands validate specific aspects of the environment but do not demonstrate application deployment, Ingress configuration, TLS, DNS, or production monitoring.

## Teardown

The project documents separate lifecycle handling for the Kubernetes controller and Terraform-managed AWS infrastructure.

If the AWS Load Balancer Controller was installed separately through Helm, it is removed through Helm before the Terraform-managed infrastructure is destroyed.

Terraform is then used to destroy the AWS resources defined by the project.

## Architecture Takeaway

The primary technical lesson is that EKS security involves multiple boundaries that should be designed independently:

- Network placement determines where Kubernetes compute runs.
- EKS endpoint configuration determines how the Kubernetes API can be reached.
- IRSA determines how Kubernetes workloads obtain AWS permissions.
- IAM trust policies determine which workload identities can assume AWS roles.
- Infrastructure-as-Code provides a repeatable definition of the AWS environment.

Separating these concerns produces a clearer security architecture and avoids treating the EKS cluster as a single security boundary.
