variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "ecr_retention_count" {
  description = "Number of ECR images to retain"
  type        = number
  default     = 3
}