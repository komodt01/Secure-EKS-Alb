# Executive Case Study – Secure Amazon EKS Architecture

## Business Context

Organizations adopting Kubernetes need to balance application scalability with network isolation, identity controls, and manageable cloud infrastructure.

This project explores that problem using Amazon EKS, with an emphasis on establishing a secure infrastructure and identity foundation rather than building a complete production Kubernetes platform.

## Architecture Challenge

The design needed to address several fundamental concerns:

- Keep Kubernetes worker nodes out of the public network tier.
- Provide separate public and private subnet layers.
- Avoid embedding AWS credentials in Kubernetes workloads.
- Establish an identity mechanism for Kubernetes services that require access to AWS APIs.
- Create infrastructure that can be consistently defined and reproduced.

## Architecture Approach

The environment uses a VPC spanning two Availability Zones with separate public and private subnets.

Amazon EKS managed worker nodes are placed in the private subnets, while the public subnet tier is available for resources that require internet-facing connectivity.

IAM Roles for Service Accounts (IRSA) provides the identity integration between Kubernetes and AWS IAM. An IAM role and trust relationship are defined specifically for the AWS Load Balancer Controller service account.

Terraform defines the VPC, networking, EKS cluster, managed node group, IRSA configuration, and supporting IAM resources.

## Security Value

The architecture demonstrates several security principles relevant to enterprise Kubernetes environments:

- Network segmentation between public-facing and workload infrastructure.
- Private placement of Kubernetes worker nodes.
- Workload-specific AWS identity through IRSA.
- Restricted trust between an IAM role and a specific Kubernetes service account.
- Infrastructure-as-Code for repeatability and change visibility.
- Separation between AWS infrastructure provisioning and Kubernetes controller lifecycle management.

## Key Architecture Decision

A central design decision was to separate the Kubernetes workload identity from the permissions of the underlying EKS worker nodes.

Rather than relying on node-level AWS permissions for the AWS Load Balancer Controller, the architecture establishes an IRSA trust relationship for the controller's Kubernetes service account.

This creates a clearer identity boundary and provides a foundation for managing AWS permissions at the workload level.

## Project Scope

The project demonstrates the AWS infrastructure and identity foundation required to support an EKS environment and AWS Load Balancer Controller integration.

Application workloads, Kubernetes Ingress resources, TLS, DNS, centralized logging, and production monitoring are outside the implemented scope.

The result is a focused architecture demonstrating how network placement, Kubernetes infrastructure, and AWS identity controls can be designed together before additional application and platform capabilities are introduced.
