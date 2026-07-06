#!/usr/bin/env bash
set -euo pipefail

REGISTRY="${REGISTRY:-ghcr.io/example/production-platform}"
TAG="${TAG:-local}"

for service in frontend backend auth notification; do
  docker build -t "${REGISTRY}/${service}:${TAG}" "services/${service}"
done
