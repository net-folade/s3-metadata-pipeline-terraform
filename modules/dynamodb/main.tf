terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.100"
    }
  }
}

# prevent_destroy only accepts a literal, so it cannot be driven by a variable directly.
# Two near-identical blocks selected by count is the workaround: exactly one is ever created,
# and callers pick with var.prevent_destroy.
resource "aws_dynamodb_table" "this" {
  count = var.prevent_destroy ? 0 : 1

  name                        = var.table_name
  billing_mode                = var.billing_mode
  hash_key                    = var.hash_key
  deletion_protection_enabled = var.deletion_protection_enabled

  attribute {
    name = var.hash_key
    type = var.hash_key_type
  }

  tags = var.tags
}

# Identical to aws_dynamodb_table.this apart from the lifecycle block.
resource "aws_dynamodb_table" "protected" {
  count = var.prevent_destroy ? 1 : 0

  name                        = var.table_name
  billing_mode                = var.billing_mode
  hash_key                    = var.hash_key
  deletion_protection_enabled = var.deletion_protection_enabled

  attribute {
    name = var.hash_key
    type = var.hash_key_type
  }

  tags = var.tags

  lifecycle {
    prevent_destroy = true
  }
}
