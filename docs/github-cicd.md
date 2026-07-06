# GitHub Push and CI/CD Guide

This project already has a GitHub Actions workflow at:

```text
.github/workflows/ci-cd.yaml
```

The workflow does this:

1. Builds Docker images for `frontend`, `backend`, `auth`, and `notification`.
2. Pushes images to Docker Hub repository `kmc173/production-platform`.
3. Scans images with Trivy.
4. Deploys to Kubernetes using Helm.

## Important CI/CD note

GitHub Actions runs on GitHub cloud servers by default.

That means automatic deployment will work only if your Kubernetes cluster is reachable from GitHub Actions.

Use one of these options:

- Cloud Kubernetes: EKS, AKS, GKE, DigitalOcean Kubernetes, Oracle OKE.
- Self-hosted GitHub Actions runner on your machine, if you want to deploy to local Minikube.
- Manual local deploy with `./scripts/deploy-dockerhub.sh`.

For local Minikube, GitHub Actions can build and push Docker images, but it cannot directly reach your Minikube cluster unless you configure a self-hosted runner.

## 1. Create GitHub repository

Create a new empty repo in GitHub, for example:

```text
https://github.com/kmc173/production-platform.git
```

Do not initialize it with README if you want to push this existing project cleanly.

## 2. Initialize Git locally

From the project root:

```bash
cd "/Users/kammamadan/Production Kubernetes Platform"
git init
git branch -M main
git add .
git commit -m "Initial production Kubernetes platform"
```

## 3. Connect local project to GitHub

Replace the URL with your real GitHub repository:

```bash
git remote add origin https://github.com/kmc173/production-platform.git
git push -u origin main
```

If Git asks for password, use a GitHub Personal Access Token, not your GitHub account password.

## 4. Add GitHub repository secrets

Open your GitHub repo:

```text
Settings -> Secrets and variables -> Actions -> New repository secret
```

Add:

```text
DOCKERHUB_USERNAME
DOCKERHUB_TOKEN
KUBE_CONFIG
```

### DOCKERHUB_USERNAME

Your Docker Hub username:

```text
kmc173
```

### DOCKERHUB_TOKEN

Create this in Docker Hub:

```text
Docker Hub -> Account Settings -> Personal access tokens -> Generate new token
```

Use the token as `DOCKERHUB_TOKEN`.

The token must have write access. If Docker Hub offers permission choices, choose a token that can read and write repositories. A read-only token will let the workflow start but the image push will fail with:

```text
401 Unauthorized: access token has insufficient scopes
```

Also confirm the token belongs to Docker Hub user `kmc173`, because the workflow pushes to:

```text
kmc173/production-platform
```

### KUBE_CONFIG

This is needed only for automatic Kubernetes deploy.

For a cloud cluster:

```bash
cat ~/.kube/config | base64
```

Copy the full output into the `KUBE_CONFIG` GitHub secret.

For local Minikube, do not use GitHub-hosted runners for deploy. Use a self-hosted runner or deploy manually.

## 5. How CI/CD works

When you push to `main`:

```bash
git add .
git commit -m "Update platform"
git push
```

GitHub Actions will:

1. Build these images:

```text
kmc173/production-platform:frontend-1.0.1
kmc173/production-platform:backend-1.0.1
kmc173/production-platform:auth-1.0.1
kmc173/production-platform:notification-1.0.1
```

2. Also push latest tags:

```text
kmc173/production-platform:frontend-latest
kmc173/production-platform:backend-latest
kmc173/production-platform:auth-latest
kmc173/production-platform:notification-latest
```

3. Run Trivy security scanning.
4. Run Helm deploy:

```bash
helm upgrade --install production-platform helm/production-platform
```

## 6. Manual Docker Hub push

If you want to push images yourself:

```bash
docker login
./scripts/push-dockerhub.sh
```

## 7. Manual Kubernetes deploy from Docker Hub

```bash
./scripts/deploy-dockerhub.sh
```

## 8. Check GitHub Actions

After pushing, open:

```text
GitHub repo -> Actions -> build-scan-deploy
```

Check each job:

- `build-scan-push`
- `deploy`

If deploy fails because Kubernetes is unreachable, use a cloud cluster or a self-hosted runner.
