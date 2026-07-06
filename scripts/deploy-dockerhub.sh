#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-production-platform}"
RELEASE="${RELEASE:-production-platform}"
VERSION="${VERSION:-latest}"

helm upgrade --install "${RELEASE}" helm/production-platform \
  --namespace "${NAMESPACE}" \
  --create-namespace \
  -f helm/production-platform/values-dockerhub.yaml \
  --set services.frontend.tag="frontend-${VERSION}" \
  --set services.backend.tag="backend-${VERSION}" \
  --set services.auth.tag="auth-${VERSION}" \
  --set services.notification.tag="notification-${VERSION}" \
  --wait --timeout 10m

echo "Deployment complete."
echo "Check pods: kubectl get pods -n ${NAMESPACE}"
