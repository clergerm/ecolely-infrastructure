# Define environment variable
variable "environment" {
  description = "Deployment environment"
  type        = string
}

# Define aws_region variable
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}