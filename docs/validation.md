# EKS Validation

The following commands were used to validate access to the EKS environment and inspect key Kubernetes components during the project.

## Configure Kubernetes Access

Update the local kubeconfig to connect `kubectl` to the EKS cluster:

`aws eks update-kubeconfig --region us-east-1 --name secure-eks-cluster`

This configures the local Kubernetes client to communicate with the EKS API endpoint.

## Validate Worker Nodes

Verify that Kubernetes can see the EKS worker nodes:

`kubectl get nodes`

This confirms connectivity to the cluster and provides the status of registered worker nodes.

## Check AWS Load Balancer Controller

Check for the AWS Load Balancer Controller deployment in the `kube-system` namespace:

`kubectl get deployment -n kube-system aws-load-balancer-controller`

This command checks whether the controller deployment exists and reports its Kubernetes deployment status.

## Validation Scope

These commands provide operational validation of cluster access, worker-node registration, and the presence of the AWS Load Balancer Controller deployment. They do not by themselves validate application workloads, Kubernetes Ingress resources, TLS, DNS, or production monitoring.
