# Docker Hub Deployment

Your Docker Hub repository:

```text
kmc173/production-platform
```

Because this is one Docker repository, this project stores each service as a different image tag:

```text
kmc173/production-platform:frontend-latest
kmc173/production-platform:backend-latest
kmc173/production-platform:auth-latest
kmc173/production-platform:notification-latest
```

## 1. Login to Docker Hub

```bash
docker login
```

Use your Docker Hub username and access token/password.

## 2. Build and push images

From the project root:

```bash
cd "/Users/kammamadan/Production Kubernetes Platform"
./scripts/push-dockerhub.sh
```

To push a custom version:

```bash
VERSION=v1 ./scripts/push-dockerhub.sh
```

That creates:

```text
kmc173/production-platform:frontend-v1
kmc173/production-platform:backend-v1
kmc173/production-platform:auth-v1
kmc173/production-platform:notification-v1
```

## 3. Deploy from Docker Hub

Deploy latest tags:

```bash
./scripts/deploy-dockerhub.sh
```

Deploy a custom version:

```bash
VERSION=v1 ./scripts/deploy-dockerhub.sh
```

## GitHub Actions secrets

For automatic CI/CD, add these repository secrets in GitHub:

```text
DOCKERHUB_USERNAME
DOCKERHUB_TOKEN
KUBE_CONFIG
```

`KUBE_CONFIG` must be your target cluster kubeconfig encoded as base64.

## 4. Verify

```bash
kubectl get pods -n production-platform
kubectl get svc -n production-platform
kubectl get ingress -n production-platform
```

## 5. Open locally with Minikube

Run:

```bash
kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 8088:80
```

Add host entry:

```bash
sudo sh -c 'echo "127.0.0.1 app.example.com" >> /etc/hosts'
```

Open:

```text
http://app.example.com:8088
```
