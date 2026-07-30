output "bucket_name" {
  value = aws_s3_bucket.uploads.bucket
}
output "table_name" {
  value = aws_dynamodb_table.metadata.name
}
output "function_name" {
  value = aws_lambda_function.processor.function_name
}
output "upload_command" {
  value = "aws s3 cp <file> s3://${aws_s3_bucket.uploads.bucket}/uploads/"
}