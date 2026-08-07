region      = "us-east-1"
project     = "s3-metadata-pipeline"
environment = "dev"

# Change this if the bucket name is already taken; S3 names are global.
bucket_suffix = "1tg0t"

# Guardrails are deliberately off in dev so the stack can be torn down freely.
log_retention_in_days        = 7
dynamodb_deletion_protection = false
dynamodb_prevent_destroy     = false
lambda_reserved_concurrency  = -1
