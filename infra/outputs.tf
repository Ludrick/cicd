###############################################################################
# Outputs
###############################################################################
output "bucket_name" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.calls_env4.bucket
}

output "bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = aws_s3_bucket.calls_env4.arn
}
