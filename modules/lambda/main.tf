terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.100"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.8"
    }
  }
}

# Both paths arrive as variables: path.module here would resolve to modules/lambda,
# not the repo root, so the caller computes them from path.root instead.
data "archive_file" "lambda" {
  type        = "zip"
  source_file = var.source_file
  output_path = var.output_path
}

resource "aws_lambda_function" "this" {
  function_name    = var.function_name
  role             = var.role_arn
  handler          = var.handler
  runtime          = var.runtime
  filename         = data.archive_file.lambda.output_path
  source_code_hash = data.archive_file.lambda.output_base64sha256
  timeout          = var.timeout

  # -1 means unreserved; prod sets a real cap so one function cannot drain account concurrency.
  reserved_concurrent_executions = var.reserved_concurrent_executions

  environment {
    variables = { TABLE_NAME = var.table_name }
  }

  tags = var.tags

  # Ensures the log group is Terraform-managed before Lambda can auto-create it untagged.
  depends_on = [aws_cloudwatch_log_group.this]
}

# The log group lives here rather than in its own module: its name is dictated by the
# function name and it has no life of its own once the function is gone.
resource "aws_cloudwatch_log_group" "this" {
  name              = var.log_group_name
  retention_in_days = var.log_retention_in_days
  tags              = var.tags
}
