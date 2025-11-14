Technologies Used
Amazon EKS

What: Managed Kubernetes service on AWS.
Why: Provides scalable, secure container orchestration.
How: Terraform module provisions EKS cluster and node groups.
IAM Roles for Service Accounts (IRSA)

What: Enables Kubernetes pods to assume IAM roles.
Why: Grants least-privilege access to AWS resources.
How: Terraform configures trust relationship and permissions.
AWS Load Balancer Controller

What: Manages AWS ALBs for Kubernetes services.
Why: Provides Kubernetes-native management of ALB resources.
How: Installed via Helm and configured with IRSA role.
Terraform

What: IaC tool to automate resource provisioning.
Why: Ensures repeatable, versioned deployments.
How: Main module provisions VPC, EKS, IAM, and Helm resources.
