#!/usr/bin/env bash
set -euo pipefail

ENVIRONMENT="${1:-}"
CONFIRM_APPLY="${CONFIRM_APPLY:-}"

if [[ "$ENVIRONMENT" != "dev" && "$ENVIRONMENT" != "prod" ]]; then
  echo "usage: CONFIRM_APPLY=APPLY $0 <dev|prod>" >&2
  exit 64
fi

[[ "$CONFIRM_APPLY" == "APPLY" ]] || {
  echo "Refusing to apply. Set CONFIRM_APPLY=APPLY after reviewing the plan." >&2
  exit 77
}

terraform -chdir=infra apply \
  -var="environment=$ENVIRONMENT"
