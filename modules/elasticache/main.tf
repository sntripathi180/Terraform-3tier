locals {
    name_prefix = "${var.project_name}-${var.environment}"

}

resource "aws_elasticache_subnet_group" "this" {
    name = "${local.name_prefix}-redis-subnet-group"
    subnet_ids = var.subnet_ids

    tags = merge(var.tags,{
        Name = "${local.name_prefix}-redis-subnet-group"

    })
}

resource "aws_elasticache_cluster" "this" {
    cluster_id = "${local.name_prefix}-redis"
    engine = "redis"
    engine_version = var.engine_version
    node_type = var.node_type
    num_cache_nodes =1 
    port = var.port

    subnet_group_name = aws_elasticache_subnet_group.this.name
    security_group_ids = var.vpc_security_group_ids

    tags = merge(var.tags,{
        Name = "${local.name_prefix}-redis"
    })
 }