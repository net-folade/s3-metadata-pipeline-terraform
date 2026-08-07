variable "bucket_name" {
  description = "Full bucket name, already composed by the caller; must be globally unique"
  type        = string
}

variable "function_name" {
  description = "Name of the function this bucket is allowed to invoke"
  type        = string
}

variable "function_arn" {
  description = "ARN of the function the notification targets"
  type        = string
}

variable "account_id" {
  description = "Account ID the invoke grant is scoped to"
  type        = string
}

variable "versioning_enabled" {
  description = "Whether object versioning is enabled on the bucket"
  type        = bool
  default     = true
}

variable "notification_prefix" {
  description = "Key prefix that triggers the notification; objects outside it are ignored"
  type        = string
  default     = "uploads/"
}

variable "notification_events" {
  description = "S3 events that invoke the function"
  type        = list(string)
  default     = ["s3:ObjectCreated:*"]
}

variable "tags" {
  description = "Tags applied to the bucket"
  type        = map(string)
  default     = {}
}
