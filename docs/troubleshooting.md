# Troubleshooting

## Pods

```bash
kubectl get pods -n production-platform
kubectl describe pod -n production-platform <pod>
kubectl logs -n production-platform <pod>
```

## Services and Ingress

```bash
kubectl get svc,ingress -n production-platform
kubectl describe ingress -n production-platform
```

Check that DNS points to the ingress load balancer address and that TLS certificates are ready:

```bash
kubectl get certificate,challenge,order -A
```

## MongoDB Persistence

Delete the MongoDB pod and verify that data remains after the StatefulSet recreates it:

```bash
kubectl delete pod -n production-platform -l app.kubernetes.io/component=mongodb
kubectl get pvc -n production-platform
```

## HPA

```bash
kubectl get hpa -n production-platform
kubectl describe hpa -n production-platform
```

If targets show `unknown`, confirm Metrics Server is installed and reachable.
