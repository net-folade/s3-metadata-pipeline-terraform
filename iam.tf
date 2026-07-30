data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "lambda_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "lambda_permissions" {
  statement {
    effect    = "Allow"
    actions   = ["dynamodb:PutItem"]
    resources = [aws_dynamodb_table.metadata.arn]
  }
  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.uploads.arn}/uploads/*"]
  }
  statement {
    effect    = "Allow"
    actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.function_name}:*"]
  }
}

resource "aws_iam_role" "lambda" {
  name               = "${var.function_name}-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_trust.json
}

resource "aws_iam_role_policy" "lambda_permissions" {
  name   = "${var.function_name}-permissions"
  role   = aws_iam_role.lambda.id
  policy = data.aws_iam_policy_document.lambda_permissions.json
}





















/*
--policy attachment --with this the policy exists and can be attachned. 
--inline attachment --above/uncommented/ the poolicy is written inline 'aws_iam_role_policy' 
            and no attachment resource at all 


resource "aws_iam_policy" "lambda_permissions" {
    name = "${var.bucket_name}-role"
    policy = data.aws_iam_policy_document.lambda_permissions.json
}

 resource "aws_iam_role_policy_attachment" "lambda_policy" {
    role = aws_iam_role.lambda.name 
    policy_arn = aws_iam_policy.lambda_permissions.arn
} */

