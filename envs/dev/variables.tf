variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Project name; first segment of every resource name"
  type        = string
  default     = "s3-metadata-pipeline"
}

variable "environment" {
  description = "Environment name; second segment of every resource name"
  type        = string
  default     = "dev"
}

variable "bucket_suffix" {
  description = "Random-ish suffix that makes the bucket name globally unique"
  type        = string
  default     = "1tg0t"
}

variable "log_retention_in_days" {
  description = "CloudWatch log retention for the processor function"
  type        = number
  default     = 7
}

variable "dynamodb_deletion_protection" {
  description = "Blocks table deletion through the AWS API"
  type        = bool
  default     = false
}

variable "dynamodb_prevent_destroy" {
  description = "Blocks table deletion through Terraform"
  type        = bool
  default     = false
}

variable "lambda_reserved_concurrency" {
  description = "Reserved concurrency for the processor; -1 leaves it unreserved"
  type        = number
  default     = -1
}
