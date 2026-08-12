locals {
    name_prefix = "${var.project_name}-${var.environment}"
}

resource "aws_lb" "this" {
    name = "${local.name_prefix}-${var.name}"
    internal = var.internal
    load_balancer_type = "application"
    subnets = var.subnet_ids
    security_groups  = var.security_group_ids

    tags = merge(var.tags,{
        Name = "${local.name_prefix}-${var.name}-alb"
    })
}


resource "aws_lb_target_group" "this" {
    name = "${local.name_prefix}-${var.name}-tg"
    port = var.target_port
    protocol = "HTTP"
    vpc_id = var.vpc_id
    target_type = "ip"
    
    health_check {
        path = var.health_check_path
        protocol = "HTTP"
        matcher = "200-399"
        interval = 30
        timeout = 5
        healthy_threshold = 2
        unhealthy_threshold = 3
    }

    tags = merge(var.tags,{
        Name = "${local.name_prefix}-${var.name}-tg"
    })

}


resource "aws_lb_listener" "this" {
    load_balancer_arn = aws_lb.this.arn
    port = var.listener_port
    protocol = "HTTP"

    default_action {
        type = "forward"
        target_group_arn = aws_lb_target_group.this.arn
    }
}