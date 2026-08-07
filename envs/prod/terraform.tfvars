region      = "us-east-1"
project     = "s3-metadata-pipeline"
environment = "prod"

# Change this if the bucket name is already taken; S3 names are global.
bucket_suffix = "1tg0t"

# Prod differs from dev only in guardrails, never in sizing or behaviour.
log_retention_in_days        = 30
dynamodb_deletion_protection = true
dynamodb_prevent_destroy     = true
lambda_reserved_concurrency  = 5

# The guardrail list also covers API Gateway stage throttling; this architecture is
# S3-triggered and has no API Gateway, so there is nothing to throttle.
