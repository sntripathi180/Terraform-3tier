output "repository_urls" {
  description = "Map of repo short name -> full ECR repository URL (used in docker push/pull and ECS task defs)"
  value       = { for name, repo in aws_ecr_repository.ecr-repo : name => repo.repository_url }
}

output "repository_arns" {
  value = { for name, repo in aws_ecr_repository.ecr-repo : name => repo.arn }
}
