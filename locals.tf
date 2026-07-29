locals {
  ecr_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1

        description = "Retain latest ${var.ecr_retention_count} images."

        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = var.ecr_retention_count
        }

        action = {
          type = "expire"
        }
      }
    ]
  })
}