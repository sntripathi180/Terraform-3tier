variable "domain_name" {
  description = "Private domain "
  type        = string
}

variable "vpc_id" {
  type = string
}

variable "records" {
  description = "Map of subdomain -> target (CNAME value)"
  type        = map(string)
  default     = {}
}

variable "a_records" {
  description = "Map of subdomain -> private IP (A record) "
  type        = map(string)
  default     = {}
}

variable "tags" {
  type    = map(string)
  default = {}
}
