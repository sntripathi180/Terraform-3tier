variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "name" {
  description = "Short identifier 'public' or 'internal'"
  type        = string
}

variable "internal" {
  description = "false = internet-facing"
  type        = bool
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}

variable "listener_port" {
  type    = number
  default = 80
}

variable "target_port" {
  description = "Port the target containers listen on"
  type        = number
}

variable "health_check_path" {
  type    = string
  default = "/"
}

variable "tags" {
  type    = map(string)
  default = {}
}
