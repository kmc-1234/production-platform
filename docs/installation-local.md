# Local Installation Guide

This guide installs the platform on your local machine with Minikube.

## What was installed

- Namespace: `production-platform`
- Frontend: 2 pods
- Backend API: 2 pods
- Auth service: 2 pods
- Notification service: 2 pods
- MongoDB: 1 StatefulSet pod with persistent storage
- NGINX Ingress
- Metrics Server
- HPA objects for autoscaling

## Prerequisites

Install these tools before running the install:

```bash
docker --version
minikube version
kubectl version --client
helm version
```

Docker Desktop must be running.

## One-command install

From the project root:

```bash
cd "/Users/kammamadan/Production Kubernetes Platform"
./scripts/deploy-local.sh
```

The script will:

1. Start Minikube if it is not already running.
2. Enable NGINX Ingress.
3. Enable Metrics Server.
4. Build all four application images inside Minikube.
5. Install or upgrade the Helm release.
6. Wait until the deployment is ready.

## Verify installation

```bash
kubectl get pods -n production-platform
kubectl get svc -n production-platform
kubectl get ingress -n production-platform
kubectl get hpa -n production-platform
```

Expected pod result:

```text
auth             2/2 pods running
backend          2/2 pods running
frontend         2/2 pods running
notification     2/2 pods running
mongodb          1/1 pod running
```

## Open the application

Recommended local method:

```bash
kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 8088:80
```

In a second terminal, add this host entry:

```bash
sudo sh -c 'echo "127.0.0.1 app.example.com" >> /etc/hosts'
```

Open:

```text
http://app.example.com:8088
```

Quick API test:

```bash
curl -H 'Host: app.example.com' http://127.0.0.1:8088/api/products
```

Alternative method:

```bash
minikube tunnel
```

Then map the Minikube IP:

```bash
minikube ip
sudo sh -c 'echo "<MINIKUBE_IP> app.example.com" >> /etc/hosts'
```

Open:

```text
http://app.example.com
```

## Useful commands

Check logs:

```bash
kubectl logs -n production-platform deploy/production-platform-production-platform-backend
```

Restart one service:

```bash
kubectl rollout restart deployment -n production-platform production-platform-production-platform-backend
```

Watch pods:

```bash
kubectl get pods -n production-platform -w
```

Validate Helm chart:

```bash
./scripts/validate.sh
```

## Uninstall

Remove the application:

```bash
helm uninstall production-platform -n production-platform
kubectl delete namespace production-platform
```

Stop Minikube:

```bash
minikube stop
```

Delete Minikube completely:

```bash
minikube delete
```

## Current verified result

On this machine, the install completed successfully:

- Helm release: `production-platform`
- Namespace: `production-platform`
- Status: `deployed`
- Ingress host: `app.example.com`
- Verified frontend response: `HTTP/1.1 200 OK`
- Verified API response: `/api/products` returned product JSON
