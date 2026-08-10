output "public_alb_sg_id" {
    value = aws_security_group.public_alb.id
}

output "internal_alb_sg_id" {
    value = aws_security_group.internal_alb.id
}

output "frontend_ecs_sg_id" {
    value = aws_security_group.frontend_ecs.id
}

output "backend_ecs_sg_id" {
    value = aws_security_group.backend_ecs.id
}

output "mysql_sg_id" {
    value = aws_security_group.mysql.id
}

output "postgres_sg_id" {
    value = aws_security_group.postgres.id
}

output "redis_sg_id" {
    value = aws_security_group.redis.id
}

output "management_sg_id" {
    value = aws_security_group.management.id
}

output "ecs_instances_sg_id" {
    value = aws_security_group.ecs_instances.id
}
output "vpn_sg_id" {
    value = aws_security_group.vpn.id
}
