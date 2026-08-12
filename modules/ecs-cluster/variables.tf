variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "instance_subnet_ids" {
  description = "Private subnets the EC2 instances launch into"
  type        = list(string)
}

variable "instance_security_group_id" {
  type = string
}

variable "instance_profile_name" {
  type = string
}

variable "instance_type" {
  type        = string
  default     = "t3.micro"
}

variable "min_size" {
  type    = number
  default = 1
}

variable "max_size" {
  type    = number
  default = 2
}

variable "desired_capacity" {
  type    = number
  default = 1
}

variable "tags" {
  type    = map(string)
  default = {}
}
