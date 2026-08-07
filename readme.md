# S3 Metadata Pipeline — Terraform

> Event-driven pipeline that extracts text metadata from documents uploaded to S3 and writes it to DynamoDB, provisioned entirely with Terraform.

> **Companion repo:** This project was first implemented manually with the AWS CLI before being rebuilt with Terraform. See the CLI version: [s3-metadata-pipeline-cli](https://github.com/net-folade/-s3-metadata-pipeline-cli)

### Architecture

`S3 (uploads/ prefix) → Lambda → DynamoDB`

An object created under the `uploads/` prefix emits an `s3:ObjectCreated:*` event, which invokes a lambda. The function reads the object, derives metadata, and writes one item per document to DynamoDB. Logs go to a CloudWatch log group managed by Terraform.

### Build Process

The configuration is split into reusable modules and per-environment roots.

```
modules/
├── dynamodb/   the metadata table, plus its deletion guardrails
├── iam/        the Lambda execution role and its inline permissions policy
├── lambda/     the function, its packaged source, and its CloudWatch log group
└── s3/         the uploads bucket, versioning, the event notification, and the invoke grant
envs/
├── dev/
└── prod/
```

Each module owns one AWS service and reaches outside itself only through declared inputs — no module contains a `provider` block, and none composes its own resource names. IAM is deliberately separate: the `lambda` module accepts a `role_arn` rather than creating a role, so it stays usable for functions with entirely different permissions.

`envs/dev` and `envs/prod` are the only Terraform roots. Each configures the provider once, composes every resource name from a `name_prefix` local, and wires the modules together. Because the two environments share one AWS account, the environment name is part of every resource name; because they keep separate state files, either can be applied without touching the other.

The two environments call the same modules and differ only in guardrails, never in behaviour or sizing:

| Setting | dev | prod |
|---|---|---|
| CloudWatch log retention | 7 days | 30 days |
| DynamoDB deletion protection | off | on |
| DynamoDB `prevent_destroy` | absent | enforced |
| Lambda reserved concurrency | unreserved | 5 |

### Features

- Processes S3 uploads automatically
- Extracts document metadata (size, type, word/line counts)
- Supports Markdown heading detection
- Handles multiple S3 records per invocation
- Stores one metadata record per document in DynamoDB

### Design Decisions & Tradeoffs

- **Terraform over the AWS CLI.** Replaces manual provisioning and teardown scripts with declarative, repeatable infrastructure.
- **DynamoDB over RDS.** Optimized for simple key-based lookups with no server management or idle cost.
- **S3 event notifications over polling.** The function runs only when new objects are uploaded, eliminating scheduled or idle compute.
- **`archive_file` + `source_code_hash`.** Lambda packages are built automatically, and source changes trigger redeployment without committing ZIP files.
- **Explicit CloudWatch log group.** Terraform manages log retention and lifecycle instead of relying on Lambda's default behavior.
- **One module per AWS service, IAM on its own.** Roles do not live inside the module of the service they grant access to, which keeps each module reusable independently of this pipeline's permissions.
- **Names composed in the environment root.** Modules receive complete names as inputs. Interpolating `project`/`environment` inside a module would make the module aware of an environment scheme it should not care about.


### Tech Stack

`Terraform` `AWS S3` `AWS Lambda` `DynamoDB` `IAM` `CloudWatch Logs` `Python 3.12` `boto3`

### Prerequisites

- Terraform >= 1.5
- AWS credentials configured
- AWS CLI (testing only)

### Deployment

Run Terraform from an environment root, never from the repo root.

```bash
cd envs/dev
terraform init
terraform plan
terraform apply
```

`terraform.tfvars` in each environment is applied automatically. Override `bucket_suffix` if the bucket name is already taken — S3 bucket names are globally unique.

```bash
terraform apply -var="bucket_suffix=your-unique-suffix"
```

Other variables: `envs/dev/variables.tf` and `envs/prod/variables.tf`

State is local for now. Each `providers.tf` carries a commented-out S3 backend block with a per-environment state key, ready to switch on once a state bucket exists.

Teardown:

```bash
terraform destroy
```

In `envs/prod` the table has `prevent_destroy` set, so a destroy fails until that guardrail is turned off deliberately.

### Continuous Integration

`.github/workflows/terraform.yml` runs on pull requests to `main` and on pushes to `main`. It currently does formatting, validation and linting only — `terraform fmt -check -recursive`, `terraform init -backend=false && terraform validate` against both environments, and `tflint`. None of it needs AWS credentials or state.

`terraform plan` on pull requests and `terraform apply` on merge are written out in full but commented out. They stay that way until remote state exists and an IAM role trusts GitHub's OIDC provider; a plan against local state has nothing to compare against. Authentication is OIDC role assumption — no long-lived access keys anywhere, including in the commented code.

### Usage

Upload a file under the `uploads/` prefix — objects outside it are ignored. Outputs come from the environment root you applied:

```bash
cd envs/dev
aws s3 cp notes.md s3://$(terraform output -raw bucket_name)/uploads/
```

Example item:
```json
{
  "doc_id": "uploads/test.md",
  "bucket": "s3-metadata-pipeline-dev-1tg0t",
  "size_bytes": 482,
  "etag": "9d2f1c...",
  "content_type": "text/markdown",
  "line_count": 24,
  "char_count": 482,
  "word_count": 71,
  "heading_count": 3,
  "processed_at": "2026-07-30T14:02:11.418293+00:00"
}
```
### cost Considerations

Development cost is effectively $0 within the AWS Free Tier.
Production costs are dominated by S3 storage as objects accumulate. Lambda and DynamoDB remain inexpensive for low-volume workloads.

### Tested / Not Covered

- **Verified:** end-to-end upload of `.txt` and `.md` files; `heading_count` present only on Markdown.
- **Not covered:** no dead-letter queue for failed invocations; non-UTF-8 files degrade via `errors="replace"` rather than failing; only text file types tested.

### Monitoring
CloudWatch Logs, retained 7 days in dev and 30 in prod. No alarms or X-Ray tracing.

### Security

- Least-privilege IAM role
- S3 invoke permission scoped by source ARN/account
- Temporary Lambda credentials
- No secrets required

### At Production Scale

Real production isolation means a separate AWS account, with its own credentials and its own state backend, so a mistake in dev cannot reach prod at the IAM or API level. This repo does not do that. It demonstrates the code-level pattern — module boundaries, per-environment roots, separate state files, environment-specific guardrails — inside a single account.

Within one account the separation is naming and state, not a security boundary: the same credentials that can apply `envs/dev` can apply `envs/prod`. Moving to real isolation would mean an account per environment, a provider `assume_role` per root, and a backend in each account. The module code would not change, which is the point of the split.

### Future Improvements

- Dead-letter queue or Lambda on-failure destination so events aren't lost after retries
- S3 lifecycle rule to expire noncurrent object versions
- Remote state backend (S3 + DynamoDB locking) instead of local state, which also unlocks the plan/apply CI jobs
- A separate AWS account per environment, with `assume_role` in each environment's provider block
- CloudWatch alarms on Lambda errors and throttles