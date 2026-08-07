terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.100"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.8"
    }
  }

  # State is local for now. Uncomment once the state bucket and lock table exist; the key
  # is unique per environment so dev and prod can never share a state file.
  # backend "s3" {
  #   bucket         = "s3-metadata-pipeline-tfstate"
  #   key            = "envs/dev/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "s3-metadata-pipeline-tflock"
  #   encrypt        = true
  # }
}

# Configured once per environment root; the modules deliberately declare no provider blocks.
provider "aws" {
  region = var.region
}
