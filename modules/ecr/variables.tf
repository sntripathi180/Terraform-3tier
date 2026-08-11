variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "repository_names" {
  description = "Short names for each repo, [frontend,backend]"
  type        = list(string)
}

variable "image_tag_mutability" {
  description = "MUTABLE allows overwriting a tag "
  type        = string
  default     = "MUTABLE"
}

variable "scan_on_push" {
  description = "Automatically scan images for known vulnerabilities "
  type        = bool
  default     = true
}

variable "max_image_count" {
  description = "Keep only the N most recent images per repo"
  type        = number
  default     = 10
}

variable "tags" {
  type    = map(string)
  default = {}
}
