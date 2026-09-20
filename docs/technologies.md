# Technologies

## Amazon EKS

**What:** Managed Kubernetes service on AWS.

**Why:** Provides managed Kubernetes orchestration for containerized workloads.

**How:** Terraform provisions the EKS cluster and managed node group across private subnets.

## IAM Roles for Service Accounts (IRSA)

**What:** Allows Kubernetes service accounts to assume AWS IAM roles through the EKS OIDC provider.

**Why:** Provides workload-specific AWS permissions without embedding AWS credentials in Kubernetes workloads.

**How:** Terraform enables IRSA and defines an IAM trust relationship for the `aws-load-balancer-controller` service account in the `kube-system` namespace.

## AWS Load Balancer Controller

**What:** Kubernetes controller used to integrate Kubernetes workloads with AWS Elastic Load Balancing.

**Why:** Enables Kubernetes resources to use AWS load-balancing capabilities.

**How:** The project defines an IAM role, IRSA trust relationship, and controller permissions required to support the AWS Load Balancer Controller. Controller installation is handled separately from the Terraform configuration.

## Amazon VPC

**What:** AWS networking service used to provide network isolation and routing.

**Why:** Separates internet-facing and workload network tiers.

**How:** Terraform provisions public and private subnets across two Availability Zones, with EKS worker nodes placed in the private subnets.

## Terraform

**What:** Infrastructure-as-Code tool used to define AWS infrastructure.

**Why:** Provides repeatable and version-controlled infrastructure definitions.

**How:** Terraform defines the VPC, subnets, EKS cluster, managed node group, IRSA configuration, and IAM resources used by the project.
