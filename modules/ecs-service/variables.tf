variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "name" {
  description = "Short identifier 'frontend' or 'backend'"
  type        = string
}

variable "cluster_name" {
  type = string
}

variable "capacity_provider_name" {
  type = string
}

variable "container_image" {
  description = "Full ECR image URI including tag "
  type        = string
}

variable "container_port" {
  type = number
}

variable "cpu" {
  description = "CPU units (1024 = 1 vCPU)."
  type        = number
  default     = 200
}

variable "memory" {
  description = "Memory in MB."
  type        = number
  default     = 200
}

variable "desired_count" {
  type    = number
  default = 1
}

variable "min_capacity" {
  type    = number
  default = 1
}

variable "max_capacity" {
  type    = number
  default = 3
}

variable "cpu_target_value" {
  description = "Target CPU utilization % for autoscaling"
  type        = number
  default     = 70
}

variable "subnet_ids" {
  description = "Private subnets the task ENIs launch into (frontend or backend tier)"
  type        = list(string)
}

variable "security_group_ids" {
  type = list(string)
}

variable "target_group_arn" {
  type = string
}

variable "execution_role_arn" {
  type = string
}

variable "task_role_arn" {
  type = string
}

variable "environment_variables" {
  description = "Plain (non-secret) env vars passed to the container"
  type        = map(string)
  default     = {}
}

variable "log_retention_days" {
  type    = number
  default = 7
}

variable "tags" {
  type    = map(string)
  default = {}
}
