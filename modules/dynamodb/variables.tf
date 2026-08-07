variable "table_name" {
  description = "Full table name, already composed by the caller (no interpolation happens in this module)"
  type        = string
}

variable "hash_key" {
  description = "Partition key attribute name"
  type        = string
  default     = "doc_id"
}

variable "hash_key_type" {
  description = "Partition key attribute type (S, N or B)"
  type        = string
  default     = "S"
}

variable "billing_mode" {
  description = "DynamoDB billing mode"
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "deletion_protection_enabled" {
  description = "Blocks table deletion through the AWS API"
  type        = bool
  default     = false
}

variable "prevent_destroy" {
  description = "Blocks table deletion through Terraform itself (see the comment in main.tf)"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags applied to the table"
  type        = map(string)
  default     = {}
}
