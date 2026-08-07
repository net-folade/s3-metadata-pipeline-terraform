output "function_name" {
  description = "Name of the processor function"
  value       = aws_lambda_function.this.function_name
}

output "function_arn" {
  description = "ARN of the processor function, for event source configuration"
  value       = aws_lambda_function.this.arn
}

output "invoke_arn" {
  description = "Invoke ARN, for integrations that call the function directly"
  value       = aws_lambda_function.this.invoke_arn
}

output "log_group_name" {
  description = "CloudWatch log group the function writes to"
  value       = aws_cloudwatch_log_group.this.name
}
