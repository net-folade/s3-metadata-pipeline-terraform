output "bucket_name" {
  description = "Upload bucket for this environment"
  value       = module.s3.bucket_name
}

output "table_name" {
  description = "Metadata table for this environment"
  value       = module.dynamodb.table_name
}

output "function_name" {
  description = "Processor function for this environment"
  value       = module.lambda.function_name
}

output "log_group_name" {
  description = "Where the processor writes its logs"
  value       = module.lambda.log_group_name
}

output "upload_command" {
  description = "Ready-to-run command for dropping a file into the pipeline"
  value       = "aws s3 cp <file> s3://${module.s3.bucket_name}/${module.s3.uploads_prefix}"
}
