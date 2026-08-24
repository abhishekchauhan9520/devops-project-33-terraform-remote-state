#!/usr/bin/env bash
set -euo pipefail

ENVIRONMENT="${1:-}"
shift || true

if [[ "$ENVIRONMENT" != "dev" && "$ENVIRONMENT" != "prod" ]]; then
  echo "usage: $0 <dev|prod> [terraform args...]" >&2
  exit 64
fi

terraform -chdir=infra plan \
  -var="environment=$ENVIRONMENT" \
  "$@"
