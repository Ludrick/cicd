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


resource "aws_lambda_function" "bronze_env4" {
  function_name = "cicdproj_calls_bronze_env4"
  role          = aws_iam_role.lambda_exec_role_env4.arn
  handler       = "data.bronze.handler.lambda_handler"
  runtime       = "python3.12"

  # Reference the zip file built in the pipeline. 
  # Since the pipeline zips to the root of the repo, 
  # the path in Terraform is "../function.zip" if you keep your code in "infra/"
  filename = "${path.module}/../function.zip"
  
  # Optional environment variables 
  # environment {
  #   variables = {
  #     CICDENV = "env4"
  #   }
  # }
  
  # If you want to update code only on file hash changes:
  # source_code_hash = filebase64sha256("${path.module}/../function.zip")
}



## LAMBDA ROLE

resource "aws_iam_role" "lambda_exec_role_env4" {
  name               = "lambda-exec-role-s3-dynamo-env4"
  assume_role_policy = data.aws_iam_policy_document.lambda_trust.json
}

# attach policies like AmazonS3FullAccess, AmazonDynamoDBFullAccess, etc.
resource "aws_iam_role_policy_attachment" "dynamo_s3" {
  role       = aws_iam_role.lambda_exec_role_env4.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
# ...plus other attachments as needed...





## LAMBDA NOTIFICATION

# 1) Give S3 permission to invoke the Lambda
resource "aws_lambda_permission" "allow_s3_invoke" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.bronze_env4.arn
  principal     = "s3.amazonaws.com"
  
  # The bucket that's allowed to invoke
  source_arn    = aws_s3_bucket.calls_env4.arn
  source_account = "599224842127"
}

# 2) S3 Notification
resource "aws_s3_bucket_notification" "calls_env4_notification" {
  bucket = aws_s3_bucket.calls_env4.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.bronze_env4.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "landing_zone/"
    filter_suffix       = ".json"
  }

  depends_on = [
    aws_lambda_permission.allow_s3_invoke
  ]
}
