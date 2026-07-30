variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "table_name" {
  description = "dynamodb table to store metadata"
  type        = string
  default     = "docs-metadata"
}

variable "function_name" {
  description = "lambda function handling metadata processing"
  type        = string
  default     = "s3-metadata-processor"
}

variable "bucket_name" {
  description = "bucket to store the files for processing"
  type        = string
  default     = "s3-metadata-pipeline-1tg0t-v2"
}