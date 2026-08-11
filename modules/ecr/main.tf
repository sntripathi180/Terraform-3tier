locals {
    name_prefix = "${var.project_name}-${var.environment}"
    repos = toset(var.repository_names)

}

resource "aws_ecr_repository" "ecr-repo" {
    for_each = local.repos

    name = "${local.name_prefix}-${each.value}"
    image_tag_mutability = var.image_tag_mutability

    image_scanning_configuration{
        scan_on_push = var.scan_on_push
    }

    tags = merge(var.tags,{
        Name = "${local.name_prefix}-${each.value}"
    })
}

resource "aws_ecr_lifecycle_policy" "this" {
    for_each = local.repos
    repository = aws_ecr_repository.ecr-repo[each.key].name

    policy = jsonencode ({
        rules = [
            {
                rulePriority = 1
                description = "keep only the ${var.max_image_count} most recent image"
                selection = {
                    tagStatus = "any"
                    countType = "imageCountMoreThan"
                    countNumber = var.max_image_count
                } 

                action = {
                    type = "expire"
                }
            }
        ]
    })
}