#!/usr/bin/env bash
set -euo pipefail

helm lint helm/production-platform
helm template production-platform helm/production-platform >/tmp/production-platform-rendered.yaml

if kubectl cluster-info >/dev/null 2>&1; then
  kubectl apply --dry-run=client --validate=false -f /tmp/production-platform-rendered.yaml
else
  echo "Rendered Helm manifests to /tmp/production-platform-rendered.yaml; skipped kubectl dry-run because no cluster is reachable."
fi
