# Secure EKS Ingress with AWS ALB

This project demonstrates a secure ingress pattern for Amazon EKS using the AWS Application Load Balancer (ALB). The goal is to show how to expose Kubernetes workloads to the internet while keeping worker nodes private, enforcing least privilege via IAM Roles for Service Accounts (IRSA), and tightening network paths between the ALB and EKS nodes.

The focus is on **practical, security-aware EKS design**, not on building a full production platform.

---

## Architecture Overview

At a high level:

- An **Application Load Balancer (ALB)** is deployed in public subnets.
- The **EKS cluster** and node group run in private subnets with no public IPs on worker nodes.
- **Kubernetes workloads** are exposed via an Ingress that integrates with the ALB.
- **Security groups** strictly control which traffic can flow between the ALB and the EKS nodes.
- **IAM Roles for Service Accounts (IRSA)** are used so pods can assume tightly scoped IAM roles without node-wide credentials.
- Logging and observability can be extended via CloudWatch Logs, CloudTrail, and EKS control plane logging.

This pattern is representative of how many organizations front Kubernetes workloads in a secure way on AWS: public entry at the ALB, private compute, and identity-aware access via IAM and IRSA.

---

## Repository Layout

text
secure-eks-alb/
├── README.md
├── docs/
│   ├── design_overview.md
│   ├── security_requirements.md
│   ├── risks_and_mitigations.md
│   ├── compliance_mapping.md
│   ├── technologies.md
│   ├── linux_commands_used.md
│   └── teardown.md
└── terraform/
    ├── providers.tf
    ├── variables.tf
    ├── eks.tf
    ├── alb.tf
    ├── security_groups.tf
    └── outputs.tf
