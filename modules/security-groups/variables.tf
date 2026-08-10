variable "project_name" {
    description = "Project name "
    type = string
}

variable "environment" {
    description = "Environment name (dev/staging/prod)"
    type = string
}

variable "vpc_id" {
    description = "ID of the VPC these security groups"
    type = string
}

variable "vpn_client_cidr" {
    description = "CIDR block assigned to client VPN"
    type = string
}

variable "frontend_container_port" {
    description = "Port the frontend SSR container lstend"
    type = number
    default = 3000
}

variable "backend_container_port" {
    description = "Port backend listens on "
    type = number 
    default = 8000
}

variable "alb_http_port" {
    type = number 
    default = 80
}

variable "alb_https_port" {
    type = number
    default = 443
}

variable "mysql_port" {
    type = number
    default = 3306
}

variable "postgres_port" {
    type = number
    default = 5432
}

variable "redis_port" {
     type = number
     default = 6379
}

variable "jenkins_port" {
    type = number
    default = 8080
}

variable "grafana_port" {
    type = number
    default = 3000
}

variable "kibana_port" {
    type = number
    default = 5601
}

variable "elasticsearch_port" {
    type = number
    default = 9200
}

variable "ssh_port" {
    type = number
    default = 22
}

variable "tags" {
    description = "Common Tags applied to all resource"
    type = map(string)
    default = {}
}
