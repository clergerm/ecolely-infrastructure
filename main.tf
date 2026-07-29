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

  policy = local.ecr_lifecycle_policy
}

resource "aws_ecr_repository" "ui" {
  name                 = "ecolely-ui-${var.environment}"
  image_tag_mutability = "IMMUTABLE"

  encryption_configuration {
    encryption_type = "AES256"
  }
}

resource "aws_ecr_lifecycle_policy" "ui" {
  repository = aws_ecr_repository.ui.name

  policy = local.ecr_lifecycle_policy
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
