#!/usr/bin/env bash
set -euo pipefail

ENVIRONMENT="${1:-}"
STATE_BUCKET="${STATE_BUCKET:-}"
AWS_REGION="${AWS_REGION:-ap-south-1}"

if [[ "$ENVIRONMENT" != "dev" && "$ENVIRONMENT" != "prod" ]]; then
  echo "usage: STATE_BUCKET=<bucket> AWS_REGION=<region> $0 <dev|prod>" >&2
  exit 64
fi

[[ -n "$STATE_BUCKET" ]] || { echo "STATE_BUCKET is required" >&2; exit 64; }

terraform -chdir=infra init -reconfigure \
  -backend-config="bucket=$STATE_BUCKET" \
  -backend-config="key=team-infra/$ENVIRONMENT/terraform.tfstate" \
  -backend-config="region=$AWS_REGION" \
  -backend-config="use_lockfile=true"

echo "Initialized remote backend for $ENVIRONMENT"
