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

  vpc_id             = module.networking.vpc_id
  subnet_ids         = module.networking.public_subnet_ids
  security_group_ids = [module.security_groups.public_alb_sg_id]
  target_port        = var.frontend_container_port
  health_check_path  = var.frontend_health_check_path

  tags = var.tags
}

module "alb_internal" {
  source = "../../modules/alb"

  project_name = var.project_name
  environment  = var.environment
  name         = "internal"
  internal     = true

  vpc_id             = module.networking.vpc_id
  subnet_ids         = module.networking.backend_subnet_ids
  security_group_ids = [module.security_groups.internal_alb_sg_id]
  target_port        = var.backend_container_port
  health_check_path  = var.backend_health_check_path

  tags = var.tags
}


module "ecs_cluster" {
  source = "../../modules/ecs-cluster"

  project_name = var.project_name
  environment  = var.environment

  instance_subnet_ids        = concat(module.networking.frontend_subnet_ids, module.networking.backend_subnet_ids)
  instance_security_group_id = module.security_groups.ecs_instances_sg_id
  instance_profile_name      = module.iam_ecs.instance_profile_name

  instance_type    = var.ecs_instance_type
  min_size         = var.ecs_asg_min_size
  max_size         = var.ecs_asg_max_size
  desired_capacity = var.ecs_asg_desired_capacity

  tags = var.tags
}


module "ecs_service_frontend" {
  source = "../../modules/ecs-service"

  project_name = var.project_name
  environment  = var.environment
  name         = "frontend"

  cluster_name           = module.ecs_cluster.cluster_name
  capacity_provider_name = module.ecs_cluster.capacity_provider_name

  container_image = "${module.ecr.repository_urls["frontend"]}:${var.frontend_image_tag}"
  container_port  = var.frontend_container_port
  desired_count   = var.frontend_desired_count

  subnet_ids         = module.networking.frontend_subnet_ids
  security_group_ids = [module.security_groups.frontend_ecs_sg_id]
  target_group_arn   = module.alb_public.target_group_arn

  execution_role_arn = module.iam_ecs.task_execution_role_arn
  task_role_arn      = module.iam_ecs.frontend_task_role_arn

  environment_variables = {
    BACKEND_INTERNAL_URL = "http://${module.alb_internal.lb_dns_name}"
  }

  tags = var.tags
}

module "ecs_service_backend" {
  source = "../../modules/ecs-service"

  project_name = var.project_name
  environment  = var.environment
  name         = "backend"

  cluster_name           = module.ecs_cluster.cluster_name
  capacity_provider_name = module.ecs_cluster.capacity_provider_name

  container_image = "${module.ecr.repository_urls["backend"]}:${var.backend_image_tag}"
  container_port  = var.backend_container_port
  desired_count   = var.backend_desired_count

  subnet_ids         = module.networking.backend_subnet_ids
  security_group_ids = [module.security_groups.backend_ecs_sg_id]
  target_group_arn   = module.alb_internal.target_group_arn

  execution_role_arn = module.iam_ecs.task_execution_role_arn
  task_role_arn      = module.iam_ecs.backend_task_role_arn

  environment_variables = {
    MYSQL_HOST    = module.rds_mysql.address
    MYSQL_PORT    = tostring(module.rds_mysql.port)
    MYSQL_DB_NAME = module.rds_mysql.db_name
    /*
    POSTGRES_HOST    = module.rds_postgres.address
    POSTGRES_PORT    = tostring(module.rds_postgres.port)
    POSTGRES_DB_NAME = module.rds_postgres.db_name
*/
    REDIS_HOST = module.elasticache_redis.endpoint
    REDIS_PORT = tostring(module.elasticache_redis.port)

    MYSQL_SECRET_ARN = module.rds_mysql.master_user_secret_arn
    # POSTGRES_SECRET_ARN = module.rds_postgres.master_user_secret_arn
  }

  tags = var.tags
}


module "vpn" {
  source = "../../modules/vpn"

  project_name = var.project_name
  environment  = var.environment

  vpc_id          = module.networking.vpc_id
  vpc_cidr        = var.vpc_cidr
  vpn_client_cidr = var.vpn_client_cidr

  security_group_id = module.security_groups.vpn_sg_id

  associated_subnet_ids = [module.networking.backend_subnet_ids[0]]

  additional_route_cidrs = concat(
    var.frontend_subnet_cidrs,
    [var.backend_subnet_cidrs[1]],
    var.db_subnet_cidrs,
    var.mgmt_subnet_cidrs,
  )

  client_names = var.vpn_client_names

  tags = var.tags
}

