# ---
# ECR configuration
# - Repository settings (immutability and encryption)
# - Image retention policy
# - Registry-level image scanning
# ---

resource "aws_ecr_repository" "service" {
  name                 = "ecolely-service-${var.environment}"
  image_tag_mutability = "IMMUTABLE"

  encryption_configuration {
    encryption_type = "AES256"
  }
}

resource "aws_ecr_lifecycle_policy" "service" {
  repository = aws_ecr_repository.service.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Retain only the latest 3 images."

        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 3
        }

        action = {
          type = "expire"
        }
      }
    ]
  })
}

resource "aws_ecr_registry_scanning_configuration" "registry_scanning" {
  scan_type = "BASIC"

  rule {
    scan_frequency = "SCAN_ON_PUSH"

    repository_filter {
      filter      = "ecolely-*"
      filter_type = "WILDCARD"
    }
  }
}
