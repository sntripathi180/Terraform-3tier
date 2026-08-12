output "vpc_id" {
  value = module.networking.vpc_id
}

output "public_subnet_ids" {
  value = module.networking.public_subnet_ids

}

output "frontend_subnet_ids" {
  value = module.networking.frontend_subnet_ids

}

output "backend_subnet_ids" {
  value = module.networking.backend_subnet_ids
}

output "db_subnet_ids" {
  value = module.networking.db_subnet_ids
}

output "mgmt_subnet_ids" {
  value = module.networking.mgmt_subnet_ids
}

output "nat_gateway_id" {
  value = module.networking.nat_gateway_ids
}

output "public_alb_sg_id" {
  value = module.security_groups.public_alb_sg_id
}

output "internal_alb_sg_id" {
  value = module.security_groups.internal_alb_sg_id
}


output "frontend_ecs_sg_id" {
  value = module.security_groups.frontend_ecs_sg_id
}

output "backend_ecs_sg_id" {
  value = module.security_groups.backend_ecs_sg_id
}

output "mysql_sg_id" {
  value = module.security_groups.mysql_sg_id
}

output "postgres_sg_id" {
  value = module.security_groups.postgres_sg_id
}

output "redis_sg_id" {
  value = module.security_groups.redis_sg_id
}

output "management_sg_id" {
  value = module.security_groups.management_sg_id
}

output "s3_bucket_id" {
  value = module.s3.bucket_id
}

output "ecr_repository_urls" {
  value = module.ecr.repository_urls
}

output "mysql_endpoint" {
  value = module.rds_mysql.endpoint
}

output "mysql_secret_arn" {
  description = "Secrets Manager ARN with the auto-generated MySQL master credentials"
  value       = module.rds_mysql.master_user_secret_arn
}
/*
output "postgres_endpoint" {
  value = module.rds_postgres.endpoint
}

output "postgres_secret_arn" {
  description = "Secrets Manager ARN with the auto-generated PostgreSQL master credentials"
  value       = module.rds_postgres.master_user_secret_arn
}
*/
output "redis_endpoint" {
  value = module.elasticache_redis.endpoint
}



output "public_alb_dns_name" {
  value = module.alb_public.lb_dns_name
}

output "internal_alb_dns_name" {
  value = module.alb_internal.lb_dns_name
}

output "ecs_cluster_name" {
  value = module.ecs_cluster.cluster_name
}


output "frontend_service_name" {
  value = module.ecs_service_frontend.service_name
}

output "backend_service_name" {
  value = module.ecs_service_backend.service_name
}

