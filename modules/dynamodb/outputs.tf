# one() collapses the two count-based blocks back to the single table that actually exists.
output "table_name" {
  description = "Name of the metadata table"
  value       = one(concat(aws_dynamodb_table.this[*].name, aws_dynamodb_table.protected[*].name))
}

output "table_arn" {
  description = "ARN of the metadata table, for IAM policies"
  value       = one(concat(aws_dynamodb_table.this[*].arn, aws_dynamodb_table.protected[*].arn))
}
