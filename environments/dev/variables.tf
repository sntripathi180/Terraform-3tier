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



variable "tags" {
  description = "Common tags applied to all resource"
  type        = map(string)
  default     = {}
}
