data "aws_caller_identity" "current" {}

locals {
  # dev and prod share one AWS account, so every name carries the environment.
  name_prefix = "${var.project}-${var.environment}"

  # Names are composed here and passed down complete; no module interpolates its own.
  bucket_name    = "${local.name_prefix}-${var.bucket_suffix}"
  table_name     = "${local.name_prefix}-docs-metadata"
  function_name  = "${local.name_prefix}-processor"
  log_group_name = "/aws/lambda/${local.function_name}"

  # Referencing module.s3.bucket_arn here would close the loop iam -> s3 -> lambda -> iam,
  # so the ARN is composed from the name this root already owns.
  bucket_arn = "arn:aws:s3:::${local.bucket_name}"

  # Composed rather than taken from the log group output for the same reason: the lambda
  # module owns the log group but needs the role that this ARN grants.
  log_group_arn = "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:${local.log_group_name}:*"

  tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

module "dynamodb" {
  source = "../../modules/dynamodb"

  table_name                  = local.table_name
  deletion_protection_enabled = var.dynamodb_deletion_protection
  prevent_destroy             = var.dynamodb_prevent_destroy
  tags                        = local.tags
}

module "iam" {
  source = "../../modules/iam"

  role_name     = "${local.function_name}-role"
  policy_name   = "${local.function_name}-permissions"
  table_arn     = module.dynamodb.table_arn
  bucket_arn    = local.bucket_arn
  log_group_arn = local.log_group_arn
  tags          = local.tags
}

module "lambda" {
  source = "../../modules/lambda"

  function_name  = local.function_name
  role_arn       = module.iam.role_arn
  table_name     = module.dynamodb.table_name
  log_group_name = local.log_group_name

  # path.root is this directory, so the handler is two levels up and the build artefact
  # stays inside the environment.
  source_file = "${path.root}/../../lambda/handler.py"
  output_path = "${path.root}/build/function.zip"

  log_retention_in_days          = var.log_retention_in_days
  reserved_concurrent_executions = var.lambda_reserved_concurrency
  tags                           = local.tags
}

module "s3" {
  source = "../../modules/s3"

  bucket_name   = local.bucket_name
  function_name = module.lambda.function_name
  function_arn  = module.lambda.function_arn
  account_id    = data.aws_caller_identity.current.account_id
  tags          = local.tags
}
