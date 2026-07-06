#!/usr/bin/env bash
set -euo pipefail

REPOSITORY="${REPOSITORY:-kmc173/production-platform}"
VERSION="${VERSION:-1.0.1}"

for service in frontend backend auth notification; do
  docker build -t "${REPOSITORY}:${service}-${VERSION}" "services/${service}"
  docker push "${REPOSITORY}:${service}-${VERSION}"
  docker tag "${REPOSITORY}:${service}-${VERSION}" "${REPOSITORY}:${service}-latest"
  docker push "${REPOSITORY}:${service}-latest"
done

echo "Pushed images:"
for service in frontend backend auth notification; do
  echo "  ${REPOSITORY}:${service}-${VERSION}"
  echo "  ${REPOSITORY}:${service}-latest"
done
