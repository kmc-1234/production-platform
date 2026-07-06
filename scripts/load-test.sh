#!/usr/bin/env bash
set -euo pipefail

URL="${1:-http://localhost:8080/api/products}"
REQUESTS="${REQUESTS:-200}"
CONCURRENCY="${CONCURRENCY:-20}"

if command -v hey >/dev/null 2>&1; then
  hey -n "${REQUESTS}" -c "${CONCURRENCY}" "${URL}"
  exit 0
fi

seq "${REQUESTS}" | xargs -n1 -P "${CONCURRENCY}" -I{} curl -fsS -o /dev/null "${URL}"
