resource "aws_s3_bucket" "uploads" {
    bucket = var.bucket_name
}

resource "aws_s3_bucket_versioning" "versions" {
    bucket = aws_s3_bucket.uploads.id
    versioning_configuration {status = "Enabled"}
}

resource "aws_lambda_permission" "add_permission" {
    statement_id = "AllowS3Invoke"
    action = "lambda:InvokeFunction" 
    principal = "s3.amazonaws.com"
    function_name = aws_lambda_function.processor.function_name 
    source_arn = aws_s3_bucket.uploads.arn
    source_account = data.aws_caller_identity.current.account_id
}

resource "aws_s3_bucket_notification" "notification" {
    bucket = aws_s3_bucket.uploads.id 
    lambda_function {
        lambda_function_arn = aws_lambda_function.processor.arn
        events = ["s3:ObjectCreated:*"]
        filter_prefix = "uploads/"
    }
    depends_on = [aws_lambda_permission.add_permission]
}