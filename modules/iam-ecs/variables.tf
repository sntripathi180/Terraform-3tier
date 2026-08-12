variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "backend_secret_arns" {
  description = "Secrets Manager ARNs (RDS credentials) "
  type        = list(string)
  default     = []
}

variable "tags" {
  type    = map(string)
  default = {}
}
