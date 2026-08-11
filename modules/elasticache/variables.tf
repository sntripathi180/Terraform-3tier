variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "node_type" {
 type        = string
  default     = "cache.t3.micro"
}

variable "engine_version" {
  type    = string
  default = "7.1"
}

variable "port" {
  type    = number
  default = 6379
}

variable "subnet_ids" {
  description = "DB-tier private subnet IDs"
  type        = list(string)
}

variable "vpc_security_group_ids" {
  type = list(string)
}

variable "tags" {
  type    = map(string)
  default = {}
}
