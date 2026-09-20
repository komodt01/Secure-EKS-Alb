# Secure EKS Architecture with IRSA and AWS Load Balancer Controller Integration

## Project Overview

This project demonstrates the infrastructure and identity foundation for running Amazon EKS workloads on AWS with private worker nodes and IAM Roles for Service Accounts (IRSA) configured for AWS Load Balancer Controller integration.

The project focuses on the architectural relationship between network segmentation, Kubernetes infrastructure, workload identity, and AWS IAM rather than implementing a complete production Kubernetes platform.

## Architecture

The Terraform configuration provisions:

* A VPC spanning two Availability Zones.
* Public subnets intended to support internet-facing AWS resources.
* Private subnets used by the EKS managed node group.
* NAT connectivity for resources operating from the private subnets.
* An Amazon EKS cluster running Kubernetes 1.29.
* An EKS managed node group using `t3.medium` instances.
* An EKS OIDC provider with IRSA enabled.
* An IAM role associated with the `aws-load-balancer-controller` Kubernetes service account.
* IAM permissions supporting AWS Load Balancer Controller operations.

The EKS API endpoint is configured for public access, while the managed worker nodes are deployed into private subnets.

## Security Architecture

### Private Worker Nodes

EKS worker nodes are deployed into private subnets rather than the public subnet tier. This separates Kubernetes compute resources from the public-facing network tier.

### Workload Identity with IRSA

IRSA allows Kubernetes service accounts to obtain AWS permissions through the EKS OIDC provider rather than relying on credentials embedded in workloads.

The IAM trust relationship is restricted to:

`system:serviceaccount:kube-system:aws-load-balancer-controller`

This establishes an identity boundary between the Kubernetes service account and its AWS IAM role.

### Network Segmentation

The VPC contains separate public and private subnet tiers across two Availability Zones.

Public subnets are tagged for Kubernetes ELB discovery, while private subnets are tagged for internal ELB discovery. The EKS managed node group is explicitly assigned to the private subnets.

### AWS Load Balancer Controller Integration

The repository contains the IAM role, IRSA trust relationship, and IAM permissions needed to support the AWS Load Balancer Controller.

Controller installation and Kubernetes Ingress resources are handled separately from the Terraform infrastructure defined in this repository.

## Architecture Decisions

Several design decisions are demonstrated in the project:

* Keep Kubernetes worker nodes in private subnets.
* Separate public-facing and workload subnet tiers.
* Use IRSA for workload-specific AWS permissions.
* Restrict the IRSA trust relationship to a specific Kubernetes service account.
* Define infrastructure through Terraform for repeatability and version control.
* Separate AWS infrastructure provisioning from Kubernetes controller installation.

## Repository Structure

```text
Secure-EKS-Alb/
├── Diagram/
│   └── Secure-EKS-Alb.png
├── docs/
│   ├── linux_commands_used.md
│   ├── teardown.md
│   └── technologies.md
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
* IAM Roles for Service Accounts (IRSA)
* AWS Load Balancer Controller integration
* Terraform
* Kubernetes
* Helm for separate controller lifecycle operations

## Scope

This repository demonstrates the AWS infrastructure and identity foundation for an EKS architecture designed to support load balancer integration.

It does not represent a complete production Kubernetes platform. Kubernetes application workloads, Ingress resources, TLS configuration, DNS configuration, centralized logging, and production monitoring are outside the Terraform implementation contained in this repository.
