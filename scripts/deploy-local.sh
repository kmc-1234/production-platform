#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-production-platform}"
RELEASE="${RELEASE:-production-platform}"
REGISTRY="${REGISTRY:-production-platform}"
TAG="${TAG:-local}"

if ! command -v minikube >/dev/null 2>&1; then
  echo "minikube is required for local install. Install it first: https://minikube.sigs.k8s.io/docs/start/"
  exit 1
fi

if ! command -v helm >/dev/null 2>&1; then
  echo "helm is required for local install. Install it first: https://helm.sh/docs/intro/install/"
  exit 1
fi

if ! minikube status >/dev/null 2>&1; then
  minikube start --driver=docker
fi

minikube addons enable ingress
minikube addons enable metrics-server

for service in frontend backend auth notification; do
  minikube image build -t "${REGISTRY}/${service}:${TAG}" "services/${service}"
done

helm upgrade --install "${RELEASE}" helm/production-platform \
  --namespace "${NAMESPACE}" \
  --create-namespace \
  --set global.imageRegistry="${REGISTRY}" \
  --set services.frontend.tag="${TAG}" \
  --set services.backend.tag="${TAG}" \
  --set services.auth.tag="${TAG}" \
  --set services.notification.tag="${TAG}" \
  --set ingress.tls.enabled=false \
  --wait --timeout 10m

echo
echo "Install complete."
echo "Check pods: kubectl get pods -n ${NAMESPACE}"
echo "Access option 1: kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 8088:80"
echo "Then add 127.0.0.1 app.example.com to /etc/hosts and open http://app.example.com:8088"
echo "Access option 2: run minikube tunnel, add $(minikube ip) app.example.com to /etc/hosts, and open http://app.example.com"
