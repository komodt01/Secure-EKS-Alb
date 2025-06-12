### Compliance Mapping

**NIST 800-53**
- AC-3 (Access Enforcement): IAM Role scoping via IRSA.
- SC-12 (Cryptographic Key Establishment): TLS for ALB endpoints.
- AU-12 (Audit Generation): EKS supports CloudTrail and CloudWatch logging.

**ISO 27001**
- A.9.2.3 (Management of Privileged Access Rights): IAM policies scoped to least privilege.
- A.13.1.1 (Network Controls): Secure VPC/subnet layout.
- A.14.2.1 (Secure Development Policy): Use of Terraform and Helm ensures repeatable secure deployments.
