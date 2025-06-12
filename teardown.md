### Teardown Instructions

1. Delete Helm release (if installed manually):
```bash
helm uninstall aws-load-balancer-controller -n kube-system
```

2. Destroy infrastructure:
```bash
terraform destroy
```

3. Clean up kubeconfig (if needed):
```bash
rm ~/.kube/config
```