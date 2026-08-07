variable "function_name" {
  description = "Full function name, already composed by the caller"
  type        = string
}

variable "role_arn" {
  description = "ARN of an existing execution role; this module creates no IAM resources"
  type        = string
}

variable "table_name" {
  description = "DynamoDB table name, exposed to the handler as TABLE_NAME"
  type        = string
}

variable "source_file" {
  description = "Absolute or root-relative path to the handler source file to package"
  type        = string
}

variable "output_path" {
  description = "Path the built deployment zip is written to"
  type        = string
}

variable "log_group_name" {
  description = "Full CloudWatch log group name, already composed by the caller"
  type        = string
}

variable "handler" {
  description = "Lambda handler entrypoint"
  type        = string
  default     = "handler.lambda_handler"
}

variable "runtime" {
  description = "Lambda runtime"
  type        = string
  default     = "python3.12"
}

variable "timeout" {
  description = "Function timeout in seconds"
  type        = number
  default     = 30
}

variable "reserved_concurrent_executions" {
  description = "Reserved concurrency; -1 leaves the function unreserved"
  type        = number
  default     = -1
}

variable "log_retention_in_days" {
  description = "CloudWatch log retention"
  type        = number
  default     = 7
}

variable "tags" {
  description = "Tags applied to the function and its log group"
  type        = map(string)
  default     = {}
}
