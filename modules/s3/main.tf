terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.100"
    }
  }
}

resource "aws_s3_bucket" "uploads" {
  bucket = var.bucket_name
  tags   = var.tags
}

resource "aws_s3_bucket_versioning" "uploads" {
  bucket = aws_s3_bucket.uploads.id

  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Suspended"
  }
}

# The invoke grant belongs to the event source, not to the function: it exists because
# this bucket calls that function, and it dies with the bucket.
resource "aws_lambda_permission" "allow_s3" {
  statement_id   = "AllowS3Invoke"
  action         = "lambda:InvokeFunction"
  principal      = "s3.amazonaws.com"
  function_name  = var.function_name
  source_arn     = aws_s3_bucket.uploads.arn
  source_account = var.account_id
}

resource "aws_s3_bucket_notification" "uploads" {
  bucket = aws_s3_bucket.uploads.id

  lambda_function {
    lambda_function_arn = var.function_arn
    events              = var.notification_events
    filter_prefix       = var.notification_prefix
  }

  # S3 validates the invoke grant when the notification is created, and nothing in the
  # notification arguments references the permission, so the edge has to be explicit.
  depends_on = [aws_lambda_permission.allow_s3]
}
