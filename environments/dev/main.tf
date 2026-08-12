module "networking" {
  source       = "../../modules/networking"
  project_name = var.project_name
  environment  = var.environment
  vpc_cidr     = var.vpc_cidr
  azs          = var.azs

  public_subnet_cidrs   = var.public_subnet_cidrs
  frontend_subnet_cidrs = var.frontend_subnet_cidrs
  backend_subnet_cidrs  = var.backend_subnet_cidrs
  db_subnet_cidrs       = var.db_subnet_cidrs
  mgmt_subnet_cidrs     = var.mgmt_subnet_cidrs
  single_nat_gateway    = var.single_nat_gateway

  tags = var.tags
}

module "security_groups" {
  source = "../../modules/security-groups"

  project_name = var.project_name
  environment  = var.environment

  vpc_id          = module.networking.vpc_id
  vpn_client_cidr = var.vpn_client_cidr

  frontend_container_port = var.frontend_container_port
  backend_container_port  = var.backend_container_port

  tags = var.tags
}

module "s3" {
  source        = "../../modules/s3"
  project_name  = var.project_name
  environment   = var.environment
  bucket_suffix = "frontend-assets"

  tags = var.tags
}

module "ecr" {
  source           = "../../modules/ecr"
  project_name     = var.project_name
  environment      = var.environment
  repository_names = var.ecr_repository_names
  max_image_count  = var.ecr_max_image_count

  tags = var.tags
}

module "rds_mysql" {
  source = "../../modules/rds"

  project_name = var.project_name
  environment  = var.environment

  name           = "mysql"
  engine         = "mysql"
  engine_version = var.mysql_engine_version
  port           = 3306
  db_name        = var.mysql_db_name

  subnet_ids             = module.networking.db_subnet_ids
  vpc_security_group_ids = [module.security_groups.mysql_sg_id]

  tags = var.tags

}
/* 
module "rds_postgres" {
  source = "../../modules/rds"

  project_name = var.project_name
  environment  = var.environment

  name           = "postgres"
  engine         = "postgres"
  engine_version = var.postgres_engine_version
  port           = 5432
  db_name        = var.postgres_db_name

  subnet_ids             = module.networking.db_subnet_ids
  vpc_security_group_ids = [module.security_groups.postgres_sg_id]

  tags = var.tags
}

*/

module "elasticache_redis" {
  source = "../../modules/elasticache"

  project_name = var.project_name
  environment  = var.environment

  subnet_ids             = module.networking.db_subnet_ids
  vpc_security_group_ids = [module.security_groups.redis_sg_id]

  tags = var.tags
}

module "iam_ecs" {
  source = "../../modules/iam-ecs"

  project_name = var.project_name
  environment  = var.environment

  backend_secret_arns = [
    module.rds_mysql.master_user_secret_arn,
    # module.rds_postgres.master_user_secret_arn,
  ]

  tags = var.tags
}


module "alb_public" {
  source = "../../modules/alb"

  project_name = var.project_name
  environment  = var.environment
  name         = "public"
  internal     = false

  vpc_id              = module.networking.vpc_id
  subnet_ids          = module.networking.public_subnet_ids
  security_group_ids  = [module.security_groups.public_alb_sg_id]
  target_port         = var.frontend_container_port
  health_check_path   = var.frontend_health_check_path

  tags = var.tags
}

module "alb_internal" {
  source = "../../modules/alb"

  project_name = var.project_name
  environment  = var.environment
  name         = "internal"
  internal     = true

  vpc_id      = module.networking.vpc_id
  subnet_ids          = module.networking.backend_subnet_ids
  security_group_ids  = [module.security_groups.internal_alb_sg_id]
  target_port         = var.backend_container_port
  health_check_path   = var.backend_health_check_path

  tags = var.tags
}