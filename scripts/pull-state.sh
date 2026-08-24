#!/usr/bin/env bash
set -euo pipefail

ENVIRONMENT="${1:-}"
OUTPUT="${2:-}"

if [[ "$ENVIRONMENT" != "dev" && "$ENVIRONMENT" != "prod" || -z "$OUTPUT" ]]; then
  echo "usage: $0 <dev|prod> <output-file>" >&2
  exit 64
fi

mkdir -p "$(dirname "$OUTPUT")"
terraform -chdir=infra state pull > "$OUTPUT"
chmod 600 "$OUTPUT"
printf 'Saved remote %s state to %s\n' "$ENVIRONMENT" "$OUTPUT"
