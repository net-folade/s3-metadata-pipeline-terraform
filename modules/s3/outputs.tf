output "bucket_name" {
  description = "Name of the uploads bucket"
  value       = aws_s3_bucket.uploads.bucket
}

output "bucket_arn" {
  description = "ARN of the uploads bucket"
  value       = aws_s3_bucket.uploads.arn
}

output "uploads_prefix" {
  description = "Prefix objects must be uploaded under to be processed"
  value       = var.notification_prefix
}
