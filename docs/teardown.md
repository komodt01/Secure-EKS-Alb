# Teardown Instructions

1. Remove the AWS Load Balancer Controller (if installed separately with Helm):

   `helm uninstall aws-load-balancer-controller -n kube-system`

2. Destroy Terraform-managed infrastructure from the Terraform directory:

   `terraform destroy`

   Review the proposed destruction plan before confirming.

3. Verify that the EKS cluster and associated Terraform-managed infrastructure have been removed from AWS.
