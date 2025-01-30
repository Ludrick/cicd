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
# Resource: S3 Bucket (env4)
###############################################################################
resource "aws_s3_bucket" "calls_env4" {
  bucket = "cicdproj-calls-env4"
}

###############################################################################
# S3 Objects to create "folders"
###############################################################################
# This creates an empty "landing_zone/" object that visually appears as a folder
resource "aws_s3_object" "landing_zone_prefix" {
  bucket = aws_s3_bucket.calls_env4.bucket
  key    = "landing_zone/"
}

# This creates an empty "processed/" object
resource "aws_s3_object" "processed_prefix" {
  bucket = aws_s3_bucket.calls_env4.bucket
  key    = "processed/"
}