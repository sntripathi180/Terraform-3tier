variable "project_name" {
    description = "Name of hte project "
    type = string 
}

variable "environment" {
    description = "environment name (dev/staging/prod)"
    type = string
}

variable "vpc_cidr" {
    description = "CIDR block of the VPC"
    type = string
}

variable "azs" {
    description = "List of the availability_zone "
    type = list(string)
}

variable "public_subnet_cidrs" {
    description = "CIDR blocks for public subnets"
    type = list(string)
}

variable "frontend_subnet_cidrs" {
    description = "CIDR block for the frontend"
    type = list(string)
}

variable "backend_subnet_cidrs" {
    description = "CIDR block for the backend"
    type = list(string)
}

variable "db_subnet_cidrs" {
    description = "CIDR block for db-tier"
    type = list(string)
}

variable "mgmt_subnet_cidrs" {
    description = "CIDR block for management-tier"
    type = list(string)
}

variable "single_nat_gateway" {
    description = "if true create only one nat"
    type = bool 
    default = false
}


variable "enable_s3_vpc_endpoint" {
    description = "if true create gateway vpc endpoints"
    type = bool
    default = true
}

variable "tags" {
    description = "Common tags applied to all resource"
    type = map(string)
    default = {}
}
