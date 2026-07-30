# S3 Metadata Pipeline — Terraform

> Event-driven pipeline that extracts text metadata from documents uploaded to S3 and writes it to DynamoDB, provisioned entirely with Terraform.

> **Companion repo:** This project was first implemented manually with the AWS CLI before being rebuilt with Terraform. See the CLI version: [s3-metadata-pipeline-cli](https://github.com/net-folade/-s3-metadata-pipeline-cli)

### Architecture

`S3 (uploads/ prefix) → Lambda → DynamoDB`

An object created under the `uploads/` prefix emits an `s3:ObjectCreated:*` event, which invokes a lambda. The function reads the object, derives metadata, and writes one item per document to DynamoDB. Logs go to a CloudWatch log group managed by Terraform.

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
- **Explicit CloudWatch log group.** Terraform manages log retention (7 days) and lifecycle instead of relying on Lambda's default behavior.


### Tech Stack

`Terraform` `AWS S3` `AWS Lambda` `DynamoDB` `IAM` `CloudWatch Logs` `Python 3.12` `boto3`

### Prerequisites

- Terraform >= 1.5
- AWS credentials configured
- AWS CLI (testing only)

### Deployment
```bash
terraform init
terraform plan
terraform apply
```

Override `bucket_name` because S3 bucket names must be globally unique.

```bash
terraform apply -var="bucket_name=your-unique-bucket-name"
```

Other variables: `variables.tf`

Teardown:

```bash
terraform destroy
```

### Usage

Upload a file under the `uploads/` prefix — objects outside it are ignored:

```bash
aws s3 cp notes.md s3://$(terraform output -raw bucket_name)/uploads/
```

Example item:
```json
{
  "doc_id": "uploads/test.md",
  "bucket": "s3-metadata-pipeline-1tg0t-v2",
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
CloudWatch Logs with 7-day retention. No alarms or X-Ray tracing.

### Security

- Least-privilege IAM role
- S3 invoke permission scoped by source ARN/account
- Temporary Lambda credentials
- No secrets required

### Future Improvements

- Dead-letter queue or Lambda on-failure destination so events aren't lost after retries
- S3 lifecycle rule to expire noncurrent object versions
- Remote state backend (S3 + DynamoDB locking) instead of local state
- Extract into reusable Terraform modules and add a non-default workspace/environment split
- CloudWatch alarms on Lambda errors and throttles