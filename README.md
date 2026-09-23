# Secure EKS Architecture with IRSA and AWS Load Balancer Controller Integration

## Project Overview

This project demonstrates an Amazon EKS infrastructure and identity foundation built around private worker-node placement, workload-specific AWS identity, and AWS Load Balancer Controller integration.

The focus is the relationship between network placement, Kubernetes infrastructure, and AWS IAM rather than a complete production Kubernetes platform.

Terraform defines the AWS infrastructure and IAM configuration, while Kubernetes controller installation is handled separately.

## What the Project Demonstrates

The Terraform configuration provisions:

* A VPC spanning two Availability Zones.
* Separate public and private subnet tiers.
* NAT connectivity for resources operating from private subnets.
* An Amazon EKS cluster running Kubernetes 1.29.
* An EKS managed node group deployed into private subnets.
* An EKS OIDC provider with IRSA enabled.
* An IAM role associated with the `aws-load-balancer-controller` Kubernetes service account.
* IAM permissions supporting AWS Load Balancer Controller operations.

The EKS API endpoint is configured for public access. This is separate from worker-node placement: the Kubernetes compute layer remains in the private subnet tier.

## Security Architecture

### Private Kubernetes Compute

The EKS managed node group is explicitly assigned to private subnets.

This keeps the worker nodes out of the public subnet tier while allowing outbound connectivity through NAT.

Private node placement is one layer of the architecture. It does not by itself provide pod-level segmentation, Kubernetes authorization, or complete workload isolation.

### Workload Identity with IRSA

The AWS Load Balancer Controller uses IAM Roles for Service Accounts rather than relying on AWS credentials embedded in the workload or unnecessarily inheriting controller permissions from the worker-node identity.

The IAM trust relationship is restricted to:

`system:serviceaccount:kube-system:aws-load-balancer-controller`

The federated trust also requires the audience:

`sts.amazonaws.com`

The resulting identity path is:

**Kubernetes Service Account → EKS OIDC Provider → AWS STS → IAM Role → AWS APIs**

This separates workload identity from node identity and provides a more specific enforcement point for AWS permissions.

### Public and Private Network Tiers

The VPC contains public and private subnets across two Availability Zones.

Public subnets are tagged for Kubernetes ELB discovery.

Private subnets are tagged for internal ELB discovery and contain the EKS managed node group.

This establishes network placement boundaries between infrastructure intended to support public-facing AWS resources and the Kubernetes compute tier.

### AWS Load Balancer Controller Integration

The repository defines the AWS-side identity and permissions required to support the AWS Load Balancer Controller.

This includes:

* The EKS OIDC integration.
* The controller IAM role.
* The service-account-specific trust relationship.
* The controller IAM permissions.

Controller installation and Kubernetes Ingress resources are managed separately from the Terraform infrastructure in this repository.

## Architecture Decisions

The project demonstrates several deliberate architecture decisions:

* Keep Kubernetes worker nodes in private subnets.
* Separate public-facing and workload network tiers.
* Treat EKS API exposure separately from worker-node placement.
* Use workload-specific AWS identity through IRSA.
* Restrict role assumption to the intended Kubernetes service account.
* Separate IAM trust from IAM permissions.
* Define AWS infrastructure through Terraform for repeatability and change visibility.
* Keep Kubernetes controller lifecycle operations separate from AWS infrastructure provisioning.

## Trust Boundaries

EKS crosses multiple security domains and should not be treated as a single security boundary.

The project identifies three particularly important paths:

**AWS-facing path**

External traffic may move from AWS load-balancing infrastructure toward Kubernetes services and workloads. The complete application and Ingress path is not implemented by this repository.

**Kubernetes management path**

Administrative access reaches the EKS control plane through the configured public API endpoint, while worker nodes remain in private subnets.

**Workload-to-AWS identity path**

The AWS Load Balancer Controller service account federates through the EKS OIDC provider and AWS STS before receiving the permissions assigned to its IAM role.

Detailed boundary analysis, including failure and bypass considerations, is documented in `docs/trust-boundaries.md`.

## Validation

Operational validation is documented in `docs/validation.md`.

The documented checks include:

* Configuring local `kubectl` access to the EKS cluster.
* Verifying registered worker nodes.
* Checking for the AWS Load Balancer Controller deployment in the `kube-system` namespace.

These checks validate selected aspects of the environment. They do not demonstrate a deployed application, Kubernetes Ingress, TLS, DNS, or production monitoring.

## Repository Structure

```text
Secure-EKS-Alb/
├── docs/
│   ├── executive-case-study.md
│   ├── linux_commands_used.md
│   ├── teardown.md
│   ├── technical-case-study.md
│   ├── technologies.md
│   ├── trust-boundaries.md
│   └── validation.md
├── policies/
│   └── alb-controller-policy.json
├── terraform/
│   ├── main.tf
│   ├── outputs.tf
│   └── variables.tf
├── .gitignore
└── README.md
```

## Technologies

* Amazon EKS
* Amazon VPC
* AWS IAM
* AWS STS
* EKS OIDC federation
* IAM Roles for Service Accounts (IRSA)
* AWS Load Balancer Controller integration
* Terraform
* Kubernetes
* Helm for separate controller lifecycle operations

## Production Considerations

This repository demonstrates a focused infrastructure and identity foundation. It is not a complete production EKS security platform.

Additional production architecture decisions would normally include:

* Kubernetes RBAC and privileged administration.
* EKS API endpoint restrictions.
* Kubernetes NetworkPolicy and workload segmentation.
* Secrets management.
* Container image security and provenance.
* Admission controls.
* Runtime security.
* Centralized audit and security logging.
* Detection and incident response.
* Ingress security.
* TLS and certificate lifecycle.
* DNS.
* WAF or other edge controls where required.
* Egress restrictions.
* Environment separation.
* Backup and recovery.

These are architecture considerations, not controls implemented by this project.

## Architecture Takeaway

The security architecture is based on separating concerns rather than treating EKS as one security boundary.

Network placement determines where Kubernetes compute runs.

The EKS endpoint determines how the Kubernetes control plane can be reached.

OIDC and STS establish the bridge between Kubernetes workload identity and AWS IAM.

IAM trust determines which workload identity may assume the controller role, while IAM permissions determine what that role may do.

Together, those controls establish the infrastructure and identity foundation on which additional Kubernetes and application security controls can be built.
