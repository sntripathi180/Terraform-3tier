locals {
    name_prefix = "${var.project_name}-${var.environment}"

}

resource "aws_security_group" "public_alb" {
    name_prefix = "${local.name_prefix}-public-alb-"
    description = "Public ALB - accepts HTTP/HTTPs from internet"
    vpc_id = var.vpc_id

    ingress {
        description = "HTTP from internet"
        from_port = var.alb_http_port
        to_port = var.alb_http_port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "HTTPs from internet"
        from_port = var.alb_https_port
        to_port = var.alb_https_port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        description = "To frontend ECS target"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = merge(var.tags,{Name = "${local.name_prefix}-public-alb-sg"})

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_security_group" "internal_alb" {
    name_prefix = "${local.name_prefix}-internal_alb-"
    description = "Internal ALB - reachable only VPN"
    vpc_id = var.vpc_id


    ingress {
        description = "HTTP from vpn clients"
        from_port = var.alb_http_port
        to_port = var.alb_http_port
        protocol = "tcp"
        cidr_blocks = [var.vpn_client_cidr]

    }

    egress {
        description = "To backend ECS target"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]

    }

    tags = merge(var.tags,{Name = "${local.name_prefix}-internal-alb-sg"})

    lifecycle {
        create_before_destroy = true
    }
}


resource "aws_security_group" "frontend_ecs" {
    name_prefix = "${local.name_prefix}-frontend-ecs-"
    description = "Frontened SSR containers "
    vpc_id = var.vpc_id

    ingress {
        description = "From Public alb only"
        from_port = var.frontend_container_port
        to_port = var.frontend_container_port
        protocol = "tcp"
        security_groups = [aws_security_group.public_alb.id]
    }

    egress {
        description = "Outbound: pull ECR images(via NAT)"
        from_port = 0
        to_port = 0 
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = merge(var.tags, {
        Name = "${local.name_prefix}-frontend-ecs-sg"
    })

    lifecycle {
        create_before_destroy = true
    }

}



resource "aws_security_group" "backend_ecs" {
    name_prefix = "${local.name_prefix}-backend-ecs-"
    description = "Backend API containers "
    vpc_id = var.vpc_id

    ingress {
        description = "From frontend ecs"
        from_port = var.backend_container_port
        to_port = var.backend_container_port
        protocol = "tcp"
        security_groups = [aws_security_group.internal_alb.id]
    }

    egress {
        description = "Outbound : pulll Ecr image via nat"
        from_port = 0 
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = merge(var.tags,{Name = "${local.name_prefix}-backend-ecs-sg"})

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_security_group" "mysql" {
    name_prefix = "${local.name_prefix}-mysql-"
    description = "RDS MySQL"
    vpc_id = var.vpc_id

    ingress {
        description = "From backend ecs"
        from_port = var.mysql_port
        to_port = var.mysql_port
        protocol = "tcp"
        security_groups = [aws_security_group.backend_ecs.id]
    }

    egress {
        from_port = 0
        to_port = 0 
        protocol  = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = merge(var.tags,{
        Name = "${local.name_prefix}-mysql-sg"
    })

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_security_group" "postgres" {
    name_prefix = "${local.name_prefix}-postgres-"
    description = "RDS postgres"
    vpc_id = var.vpc_id

    ingress {
        description = "From Backend ECS"
        from_port = var.postgres_port
        to_port = var.postgres_port
        protocol = "tcp"
        security_groups = [aws_security_group.backend_ecs.id]

    }

    egress{
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]

    }

    tags = merge(var.tags,{
        Name = "${local.name_prefix}-postgres-sg"
    })

    lifecycle {
        create_before_destroy = true
    }
}


resource "aws_security_group" "redis" {
    name_prefix = "${local.name_prefix}-redis-"
    description = "ElasticCache redis"
    vpc_id = var.vpc_id

    ingress {
        description = "From Backend ECS"
        from_port = var.redis_port
        to_port = var.redis_port
        protocol = "tcp"
        security_groups = [aws_security_group.backend_ecs.id]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = merge(var.tags,{
        Name = "${local.name_prefix}-redis-sg"
    })


    lifecycle {
        create_before_destroy = true
    }
}


resource "aws_security_group" "vpn" {
    name_prefix = "${local.name_prefix}-vpn-"
    description = "clients vpn endpoints ENIs"
    vpc_id = var.vpc_id


    ingress {
        description = "From VPN clients"
        from_port = 0
        to_port = 0 
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    

    tags = merge(var.tags,{
        Name = "${local.name_prefix}-vpn-sg"
    })


    lifecycle {
        create_before_destroy = true
    }
}


resource "aws_security_group" "ecs_instances" {
    name_prefix = "${local.name_prefix}-ecs-instances-"
    description = "ECS EC2 hosts"
    vpc_id = var.vpc_id

    egress {
        description = "All outbound traffic"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = merge(var.tags,{
        Name = "${local.name_prefix}-ecs-instances-sg"
    })


    lifecycle {
        create_before_destroy = true
    }
}


resource "aws_security_group" "management" {
    name_prefix = "${local.name_prefix}-management-"
    description = "Jenkins/Grafana/Kibana/Elastic - reachable from vpn only"
    vpc_id = var.vpc_id

    ingress{
        description = "Jenkins Ui from VPN clients"
        from_port = var.jenkins_port
        to_port = var.jenkins_port
        protocol = "tcp"
        cidr_blocks = [var.vpn_client_cidr]
    }

    ingress {
        description = "Grafana UI from VPN clients"
        from_port = var.grafana_port
        to_port = var.grafana_port
        protocol = "tcp"
        cidr_blocks = [var.vpn_client_cidr]
    }

    ingress {
        description = "Kibana UI form VPN client"
        from_port = var.kibana_port
        to_port = var.kibana_port
        protocol = "tcp"
        cidr_blocks = [var.vpn_client_cidr]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = merge(var.tags,{
        Name = "${local.name_prefix}-management-sg"
    })

    lifecycle {
        create_before_destroy = true
    }
    
}


