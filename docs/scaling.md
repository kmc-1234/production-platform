# Scaling

The Helm chart creates an HPA for every application service.

Default policy:

- Minimum pods: 2
- Maximum pods: 10
- CPU target: 70%

Install Metrics Server before testing HPA:

```bash
kubectl top nodes
kubectl top pods -n production-platform
```

Run load:

```bash
./scripts/load-test.sh http://api.example.com/api/products
```

Watch scaling:

```bash
kubectl get hpa -n production-platform -w
kubectl get pods -n production-platform -w
```

Rolling updates are configured with `maxUnavailable: 0` and `maxSurge: 1` to avoid downtime during image changes.

For blue/green deployment, install a second release with a different name and switch ingress host or service selector after validation:

```bash
helm upgrade --install production-platform-green helm/production-platform --namespace production-platform-green --create-namespace
```
