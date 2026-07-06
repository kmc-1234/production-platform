#!/usr/bin/env bash
set -euo pipefail

REPOSITORY="${REPOSITORY:-kmc173/production-platform}"
VERSION="${VERSION:-latest}"

for service in frontend backend auth notification; do
  docker build -t "${REPOSITORY}:${service}-${VERSION}" "services/${service}"
  docker push "${REPOSITORY}:${service}-${VERSION}"
done

echo "Pushed images:"
for service in frontend backend auth notification; do
  echo "  ${REPOSITORY}:${service}-${VERSION}"
done
