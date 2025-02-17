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
    bucket  = "cicdproj-tfstate"
    key     = "infra/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

###############################################################################
# AWS Provider
###############################################################################
provider "aws" {
  region = var.aws_region
}

###############################################################################
# Variables
# (Alternatively, put these in variables.tf)
###############################################################################
/*
variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region where resources will be created"
}

variable "env" {
  type        = string
  default     = "env4"
  description = "Environment suffix to append to resource names"
}
*/

###############################################################################
# IAM Policy Document for Lambda trust
###############################################################################
data "aws_iam_policy_document" "lambda_trust" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

###############################################################################
# IAM Role for Lambda
###############################################################################
resource "aws_iam_role" "lambda_exec_role_env" {
  name               = "lambda-exec-role-s3-dynamo-${var.env}"
  assume_role_policy = data.aws_iam_policy_document.lambda_trust.json
}

# Attach Managed Policies to that Role
resource "aws_iam_role_policy_attachment" "attach_lambda_basic" {
  role       = aws_iam_role.lambda_exec_role_env.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "attach_s3_full" {
  role       = aws_iam_role.lambda_exec_role_env.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "attach_dynamodb_full" {
  role       = aws_iam_role.lambda_exec_role_env.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

###############################################################################
# S3 Bucket: "cicdproj-calls-<env>"
###############################################################################
resource "aws_s3_bucket" "calls" {
  bucket = "cicdproj-calls-${var.env}"
}

resource "aws_s3_bucket_versioning" "calls_versioning" {
  bucket = aws_s3_bucket.calls.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

###############################################################################
# S3 Objects (prefixes)
###############################################################################
resource "aws_s3_object" "landing_zone_prefix" {
  bucket = aws_s3_bucket.calls.bucket
  key    = "landing_zone/"
  content = ""  # Provide empty content
}

resource "aws_s3_object" "processed_prefix" {
  bucket = aws_s3_bucket.calls.bucket
  key    = "processed/"
  content = ""  # Provide empty content
}

###############################################################################
# DynamoDB Table: "cicdproj_calls_bronze_<env>"
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

###############################################################################
# Lambda Function
###############################################################################
resource "aws_lambda_function" "bronze" {
  function_name = "cicdproj_calls_bronze_${var.env}"
  role          = aws_iam_role.lambda_exec_role_env.arn
  handler       = "data.bronze.handler.lambda_handler"
  runtime       = "python3.12"

  # We'll build 'function.zip' in the pipeline, placed at the repo root 
  filename = "${path.module}/../function.zip"
  source_code_hash = filebase64sha256("${path.module}/../function.zip")

  # If you'd like to set environment variables:
  # environment {
  #   variables = {
  #     CICDENV = var.env
  #   }
  # }
}

  resource "aws_lambda_function" "api" {
  function_name = "cicdproj_calls_api_${var.env}"
  role          = aws_iam_role.lambda_exec_role_env.arn
  handler       = "data.api.handler.lambda_handler"
  runtime       = "python3.12"

  filename = "${path.module}/../function.zip"
  source_code_hash = filebase64sha256("${path.module}/../function.zip")
  }

###############################################################################
# Lambda Permission: allow S3 to invoke the Lambda
###############################################################################
resource "aws_lambda_permission" "allow_s3_invoke" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.bronze.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.calls.arn
  source_account = "599224842127"
}

###############################################################################
# S3 -> Lambda Notification
###############################################################################
resource "aws_s3_bucket_notification" "calls_notification" {
  bucket = aws_s3_bucket.calls.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.bronze.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "landing_zone/"
    filter_suffix       = ".json"
  }

  depends_on = [
    aws_lambda_permission.allow_s3_invoke
  ]
}
