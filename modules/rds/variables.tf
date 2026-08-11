variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "name" {
  description = "Short identifier for database,'mysql' or 'postgres'"
  type        = string
}

variable "engine" {
  description = "RDS engine: 'mysql' or 'postgres'"
  type        = string
}

variable "engine_version" {
  description = "Engine version. "
  type        = string
}

variable "port" {
  type = number
}

variable "instance_class" {
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Storage in GB."
  type        = number
  default     = 20
}

variable "storage_type" {
  type        = string
  default     = "gp2"
}

variable "db_name" {
  description = "Initial database name created inside the instance"
  type        = string
}

variable "master_username" {
  type    = string
  default = "dbadmin"
}

variable "subnet_ids" {
  description = "DB-tier private subnet IDs "
  type        = list(string)
}

variable "vpc_security_group_ids" {
  type = list(string)
}

variable "multi_az" {
 type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Days of automated backups to retain."
  type        = number
  default     = 1
}

variable "skip_final_snapshot" {
  description = "true = don't create a final snapshot on destroy"
  type        = bool
  default     = true
}

variable "deletion_protection" {
  type    = bool
  default = false
}

variable "tags" {
  type    = map(string)
  default = {}
}
