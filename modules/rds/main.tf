locals {
    name_prefix = "${var.project_name}-${var.environment}"
}

resource "aws_db_subnet_group" "this" {
    name = "${local.name_prefix}-${var.name}-subnet-group"
    subnet_ids = var.subnet_ids

    tags = merge(var.tags,{
        Name = "${local.name_prefix}-${var.name}-subnet-group"
    })
}


resource "aws_db_instance" "this" {
    identifier = "${local.name_prefix}-${var.name}"

    engine = var.engine
    engine_version = var.engine_version
    instance_class = var.instance_class

    allocated_storage = var.allocated_storage
    storage_type = var.storage_type
    storage_encrypted = true

    db_name = var.db_name
    username  = var.master_username
    port = var.port 

    manage_master_user_password= true

    db_subnet_group_name = aws_db_subnet_group.this.name
    vpc_security_group_ids = var.vpc_security_group_ids
    publicly_accessible = false

    multi_az = var.multi_az
    backup_retention_period   = var.backup_retention_period
    skip_final_snapshot = var.skip_final_snapshot
    deletion_protection = var.deletion_protection
    apply_immediately = true

    tags = merge(var.tags,{
        Name = "${local.name_prefix}-${var.name}"
    })
}