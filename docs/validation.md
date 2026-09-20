# Install necessary tools
sudo apt update && sudo apt install -y unzip curl awscli

# Update kubeconfig
aws eks update-kubeconfig --region us-east-1 --name secure-eks-cluster

# Check nodes
kubectl get nodes

# Check AWS Load Balancer Controller
kubectl get deployment -n kube-system aws-load-balancer-controller
