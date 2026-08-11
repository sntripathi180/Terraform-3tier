variable "project_name" {
    type = string
}

variable "environment" {
    type = string
}

variable "bucket_suffix" {
  description = "Short suffix describing what the bucket is for, e.g. 'frontend-assets'"
  type        = string
  default     = "frontend-assets"
}


variable "enable_versioning" {
  description = "Keep old versions"
  type        = bool
  default     = true
}

variable "noncurrent_version_expiration_days" {
  description = "Days to keep old (noncurrent) object versions "
  type        = number
  default     = 30
}

variable "tags" {
  type    = map(string)
  default = {}
}