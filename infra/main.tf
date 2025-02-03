###############################################################################
# Terraform Configuration
###############################################################################
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.2.0"

  backend "s3" {
    bucket         = "cicdproj-tfstate"
    key            = "infra/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}

###############################################################################
# AWS Provider - references the variable declared in variables.tf
###############################################################################
provider "aws" {
  region = var.aws_region
}

###############################################################################
# Resource: S3 Bucket: cicdproj-calls-envx
###############################################################################
resource "aws_s3_bucket" "calls" {
  bucket = "cicdproj-calls-${var.env}"
}

###############################################################################
# S3 Objects to create "folders"
###############################################################################
resource "aws_s3_object" "landing_zone_prefix" {
  bucket = aws_s3_bucket.calls.bucket
  key    = "landing_zone/"
}

resource "aws_s3_object" "processed_prefix" {
  bucket = aws_s3_bucket.calls.bucket
  key    = "processed/"
}


###############################################################################
# DynamoDB Table: cicdproj_calls_bronze_envx
###############################################################################
resource "aws_dynamodb_table" "calls_bronze" {
  name         = "cicdproj_calls_bronze_${var.env}"
  billing_mode = "PAY_PER_REQUEST"

  hash_key  = "ip"
  range_key = "timestamp"

  attribute {
    name = "ip"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "N"
  }
}