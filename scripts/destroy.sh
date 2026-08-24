#!/usr/bin/env bash
set -euo pipefail

ENVIRONMENT="${1:-}"
CONFIRM_DESTROY="${CONFIRM_DESTROY:-}"

if [[ "$ENVIRONMENT" != "dev" && "$ENVIRONMENT" != "prod" ]]; then
  echo "usage: CONFIRM_DESTROY=DESTROY-TEAM-INFRA $0 <dev|prod>" >&2
  exit 64
fi

[[ "$CONFIRM_DESTROY" == "DESTROY-TEAM-INFRA" ]] || {
  echo "Refusing to destroy. Set CONFIRM_DESTROY=DESTROY-TEAM-INFRA after review." >&2
  exit 77
}

terraform -chdir=infra destroy -var="environment=$ENVIRONMENT"
