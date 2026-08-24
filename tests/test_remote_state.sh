#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

assert_contains() {
  local file="$1"
  local needle="$2"
  grep -Fq "$needle" "$ROOT/$file" || {
    echo "FAIL: $file missing: $needle" >&2
    exit 1
  }
}

for script in init-backend.sh plan.sh apply.sh pull-state.sh destroy.sh; do
  bash -n "$ROOT/scripts/$script"
done

assert_contains "bootstrap/main.tf" "aws_s3_bucket_versioning"
assert_contains "bootstrap/main.tf" "aws_s3_bucket_server_side_encryption_configuration"
assert_contains "bootstrap/main.tf" "aws_s3_bucket_public_access_block"
assert_contains "bootstrap/main.tf" "aws_s3_bucket_policy"
assert_contains "bootstrap/main.tf" "aws:SecureTransport"
assert_contains "infra/backend.tf" "use_lockfile = true"
assert_contains "scripts/apply.sh" "CONFIRM_APPLY=APPLY"
assert_contains "scripts/destroy.sh" "CONFIRM_DESTROY=DESTROY-TEAM-INFRA"
assert_contains "scripts/init-backend.sh" "team-infra/$ENVIRONMENT/terraform.tfstate"
assert_contains "iam/state-access-policy.example.json" "terraform.tfstate.tflock"

if grep -RqsE 'access_key|secret_key|AWS_SECRET_ACCESS_KEY|aws_session_token' bootstrap infra scripts backend iam; then
  echo "FAIL: credential-like material found" >&2
  exit 1
fi

if grep -nF '.terraform.lock.hcl' .gitignore >/dev/null 2>&1; then
  echo "FAIL: Terraform lock file must remain version-controlled" >&2
  exit 1
fi

echo "Project 33 remote-state security assertions passed."
