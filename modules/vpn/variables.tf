variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "org_name" {
  description = "Organization name embedded in the generated certificates"
  type        = string
  default     = "DreamProject"
}

variable "vpc_id" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "vpn_client_cidr" {
  description = "Address pool AWS assigns to connected VPN clients"
  type        = string
}

variable "security_group_id" {
  type = string
}

variable "associated_subnet_ids" {
  description = "Subnet the VPN endpoint's ENIs live in. "
  type        = list(string)
}

variable "additional_route_cidrs" {
  description = "CIDR blocks (other private subnet tiers) to add explicit VPN routes for, beyond the auto-created route for the associated subnet"
  type        = list(string)
  default     = []
}

variable "client_names" {
  description = "One client certificate is generated per name here"
  type        = list(string)
  default     = ["admin"]
}

variable "split_tunnel" {
  description = "true = only VPC-bound traffic goes through the VPN"
  type        = bool
  default     = true
}

variable "tags" {
  type    = map(string)
  default = {}
}
