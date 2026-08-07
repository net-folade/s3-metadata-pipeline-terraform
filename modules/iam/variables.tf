variable "role_name" {
  description = "Full role name, already composed by the caller"
  type        = string
}

variable "policy_name" {
  description = "Full name of the inline permissions policy, already composed by the caller"
  type        = string
}

variable "table_arn" {
  description = "ARN of the DynamoDB table the function writes metadata to"
  type        = string
}

variable "bucket_arn" {
  description = "ARN of the S3 bucket the function reads uploaded objects from"
  type        = string
}

variable "uploads_prefix" {
  description = "Key prefix the s3:GetObject grant is limited to"
  type        = string
  default     = "uploads/"
}

variable "log_group_arn" {
  description = "ARN of the function's CloudWatch log group, including the :* stream suffix"
  type        = string
}

variable "tags" {
  description = "Tags applied to the role"
  type        = map(string)
  default     = {}
}
