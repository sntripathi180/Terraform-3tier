variable "aws_region" {
  description = "AWS region to deploy "
  type        = string
}

variable "project_name" {
  description = "Project name "
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "azs" {
  description = "availability Zones to use"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "frontend_subnet_cidrs" {
  description = "CIDR block for frontend-tier"
  type        = list(string)
}

variable "backend_subnet_cidrs" {
  description = "CIDR block for backend tier"
  type        = list(string)
}

variable "db_subnet_cidrs" {
  description = "CIDR block for db tier"
  type        = list(string)

}

variable "mgmt_subnet_cidrs" {
  description = "CIDR blocks for management tier"
  type        = list(string)
}

variable "single_nat_gateway" {
  description = "Use a single NAT Gateway "
  type        = bool
  default     = true
}

variable "vpn_client_cidr" {
  description = "CIDR block to client VPN "
  type        = string
}

variable "ecr_repository_names" {
  description = "Short names for ECR repos, [frontend, backend]"
  type        = list(string)
  default     = ["frontend", "backend"]
}

variable "ecr_max_image_count" {
  description = "Max images to retain per ECR repo before oldest are auto-expired"
  type        = number
  default     = 10
}

variable "mysql_engine_version" {
  type    = string
  default = "8.0"
}

variable "mysql_db_name" {
  type    = string
  default = "myappdb"
}

variable "postgres_engine_version" {
  type    = string
  default = "16"
}

variable "postgres_db_name" {
  type    = string
  default = "myappdb"
}


variable "backend_container_port" {
  type    = number
  default = 8000
}

variable "frontend_container_port" {
  type    = number
  default = 3000
}


variable "frontend_health_check_path" {
  type    = string
  default = "/"
}

variable "backend_health_check_path" {
  description = "Your backend app needs to implement this endpoint and return 200"
  type        = string
  default     = "/health"
}


variable "ecs_instance_type" {
  description = "t3.micro/t2.micro are free-tier eligible"
  type        = string
  default     = "t3.micro"
}

variable "ecs_asg_min_size" {
  type    = number
  default = 1
}

variable "ecs_asg_max_size" {
  type    = number
  default = 2
}

variable "ecs_asg_desired_capacity" {
  type    = number
  default = 1
}

variable "frontend_image_tag" {
  description = "Tag to deploy for the frontend image. Push an image to ECR before applying, or the task will fail to start."
  type        = string
  default     = "latest"
}

variable "backend_image_tag" {
  type    = string
  default = "latest"
}

variable "frontend_desired_count" {
  type    = number
  default = 1
}

variable "backend_desired_count" {
  type    = number
  default = 1
}


variable "tags" {
  description = "Common tags applied to all resource"
  type        = map(string)
  default     = {}
}


variable "vpn_client_names" {
  description = "One VPN client certificate is generated per name - add your team's usernames here"
  type        = list(string)
  default     = ["admin"]
}

variable "private_domain_name" {
  type    = string
  default = "internal.myapp.local"
}
