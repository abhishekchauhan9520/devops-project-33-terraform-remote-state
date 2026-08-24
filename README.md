# Project 33 — Terraform Remote State & Team Infrastructure

A production-oriented Terraform lab showing how a team can safely share infrastructure state using an encrypted, versioned Amazon S3 backend with native S3 state locking.

## Architecture

```text
Terraform users / CI
        |
        v
   Shared S3 Backend
   - Versioning
   - SSE encryption
   - Block Public Access
   - TLS-only bucket policy
   - Native .tflock locking
        |
   +----+----+
   |         |
  dev       prod
 state      state
 objects    objects
```

## Why this design

Current Terraform supports S3-native state locking through `use_lockfile = true`. DynamoDB-based backend locking is deprecated in current Terraform documentation, so this project deliberately uses the S3 lockfile model. S3 versioning is enabled because HashiCorp recommends it for recovery from accidental deletion or human error.

## Repository layout

- `bootstrap/` — one-time creation of the remote state bucket
- `infra/` — sample infrastructure consumed through the remote backend
- `backend/` — partial backend configuration examples
- `scripts/` — safe init/plan/apply/state-recovery helpers
- `tests/` — offline configuration assertions
- `.github/workflows/` — CI validation and plan-only checks

## Bootstrap

The bootstrap stack uses local state intentionally. It creates the backend bucket before any remote backend can be initialized.

```bash
cd bootstrap
terraform init
terraform fmt -check
terraform validate
terraform plan
terraform apply
```

Do not put AWS credentials in Terraform files. Use the AWS SDK credential chain, an AWS profile, or workload identity.

## Configure the remote backend

The main Terraform configuration uses a partial S3 backend. Supply the bucket, region, and environment-specific state key at initialization time:

```bash
export STATE_BUCKET="your-unique-state-bucket"
export AWS_REGION="ap-south-1"

./scripts/init-backend.sh dev
./scripts/plan.sh dev
```

Production uses a different state key:

```bash
./scripts/init-backend.sh prod
./scripts/plan.sh prod
```

The script intentionally uses `-reconfigure` so the local `.terraform` metadata follows the selected backend configuration.

## Team locking

The backend is configured with:

```hcl
use_lockfile = true
```

Terraform creates and removes a `<state-key>.tflock` object while a state-writing operation is active. Do not use `-lock=false` in normal workflows.

## State recovery

S3 Versioning gives the team a recovery path for accidental overwrites/deletions. Pull a backup before any manual state surgery:

```bash
./scripts/pull-state.sh prod backups/prod.tfstate
```

Manual `terraform state push` is intentionally not automated in this repository because it can overwrite remote state. Use it only after review and after preserving a backup.

## CI model

CI performs formatting, validation, and plan checks only. It never applies infrastructure and it never stores AWS credentials in the repository.

Recommended GitHub deployment setup:

- GitHub Environments: `dev` and `production`
- OIDC federation to AWS roles
- Read-only/plan role for pull requests
- Separate apply role for approved production changes
- S3 object permissions scoped to the required state prefix

## Security controls

The bootstrap bucket is configured with:

- S3 Versioning
- Server-side encryption
- S3 Block Public Access
- Ownership controls
- TLS-only bucket policy
- No ACL-based public access

AWS recommends keeping S3 Block Public Access enabled and supports versioning as a data-integrity/recovery control.

## Cost and safety

The bootstrap creates an S3 bucket and therefore uses AWS infrastructure. The CI workflow is plan-only. Run `terraform apply` only when you deliberately want to create resources.

## License

MIT
