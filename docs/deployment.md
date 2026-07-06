# Deployment

## Local Cluster

1. Create a Kind or Minikube cluster.
2. Install NGINX Ingress.
3. Install Metrics Server.
4. Build images and deploy:

```bash
./scripts/deploy-local.sh
```

## Production Cluster

Install required platform services:

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo add jetstack https://charts.jetstack.io
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
```

Install application chart:

```bash
helm upgrade --install production-platform helm/production-platform \
  --namespace production-platform \
  --create-namespace \
  --set global.imageRegistry=ghcr.io/YOUR_ORG/production-platform \
  --set ingress.hosts.frontend=app.example.com \
  --set ingress.hosts.backend=api.example.com \
  --set ingress.hosts.auth=auth.example.com
```

## CI/CD

The GitHub Actions workflow builds all service images, scans them with Trivy, pushes to GHCR, and deploys with Helm. Configure repository secrets:

- `KUBE_CONFIG`: base64-encoded kubeconfig for the target cluster.
- Production secret values should be supplied through a proper secret manager or Helm value injection.
