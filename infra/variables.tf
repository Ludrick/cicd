###############################################################################
# Variables
###############################################################################
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