terraform {
  required_providers {
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

resource "tls_private_key" "ca" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "ca" {
  private_key_pem = tls_private_key.ca.private_key_pem

  subject {
    common_name  = "${local.name_prefix}-vpn-ca"
    organization = var.org_name
  }

  validity_period_hours = 87600 # 10 years
  is_ca_certificate     = true

  allowed_uses = [
    "cert_signing",
    "crl_signing",
    "digital_signature",
  ]
}



resource "tls_private_key" "server" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_cert_request" "server" {
  private_key_pem = tls_private_key.server.private_key_pem

  subject {
    common_name  = "${local.name_prefix}-vpn-server"
    organization = var.org_name
  }

    dns_names = [
    "${local.name_prefix}.internal"
  ]
}

resource "tls_locally_signed_cert" "server" {
  cert_request_pem   = tls_cert_request.server.cert_request_pem
  ca_private_key_pem = tls_private_key.ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca.cert_pem

  validity_period_hours = 87600

  allowed_uses = [
    "server_auth",
    "digital_signature",
    "key_encipherment",
  ]
}

resource "aws_acm_certificate" "server" {
  private_key       = tls_private_key.server.private_key_pem
  certificate_body  = tls_locally_signed_cert.server.cert_pem
  certificate_chain = tls_self_signed_cert.ca.cert_pem

  tags = merge(var.tags, { Name = "${local.name_prefix}-vpn-server-cert" })
}

resource "aws_acm_certificate" "ca" {
  private_key      = tls_private_key.ca.private_key_pem
  certificate_body = tls_self_signed_cert.ca.cert_pem

  tags = merge(var.tags, { Name = "${local.name_prefix}-vpn-ca-cert" })
}

resource "tls_private_key" "client" {
  for_each  = toset(var.client_names)
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_cert_request" "client" {
  for_each        = toset(var.client_names)
  private_key_pem = tls_private_key.client[each.key].private_key_pem

  subject {
    common_name  = "${local.name_prefix}-vpn-client-${each.key}"
    organization = var.org_name
  }

    dns_names = [
    "${local.name_prefix}-vpn-client-${each.key}.internal"
  ]
}

resource "tls_locally_signed_cert" "client" {
  for_each = toset(var.client_names)

  cert_request_pem   = tls_cert_request.client[each.key].cert_request_pem
  ca_private_key_pem = tls_private_key.ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca.cert_pem

  validity_period_hours = 87600

  allowed_uses = [
    "client_auth",
    "digital_signature",
  ]
}


resource "local_sensitive_file" "client_cert" {
  for_each = toset(var.client_names)
  filename = "${path.root}/generated-vpn-certs/${each.key}.crt"
  content  = tls_locally_signed_cert.client[each.key].cert_pem
}

resource "local_sensitive_file" "client_key" {
  for_each = toset(var.client_names)
  filename = "${path.root}/generated-vpn-certs/${each.key}.key"
  content  = tls_private_key.client[each.key].private_key_pem
}

resource "local_sensitive_file" "ca_cert" {
  filename = "${path.root}/generated-vpn-certs/ca.crt"
  content  = tls_self_signed_cert.ca.cert_pem
}


resource "aws_ec2_client_vpn_endpoint" "this" {
  description            = "${local.name_prefix} client vpn"
  server_certificate_arn = aws_acm_certificate.server.arn
  client_cidr_block      = var.vpn_client_cidr
  vpc_id                 = var.vpc_id
  security_group_ids     = [var.security_group_id]
  split_tunnel           = var.split_tunnel

   dns_servers = [cidrhost(var.vpc_cidr, 2)]

  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = aws_acm_certificate.ca.arn
  }
 connection_log_options {
    enabled = false
  }

  tags = merge(var.tags, { Name = "${local.name_prefix}-vpn" })
}



resource "aws_ec2_client_vpn_network_association" "this" {
  for_each = {
  for idx, subnet_id in var.associated_subnet_ids :
  idx => subnet_id
  }
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this.id
  subnet_id              = each.value
}

resource "aws_ec2_client_vpn_authorization_rule" "vpc" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this.id
  target_network_cidr    = var.vpc_cidr
  authorize_all_groups   = true
}
resource "aws_ec2_client_vpn_route" "additional" {
  for_each = toset(var.additional_route_cidrs)

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this.id
  destination_cidr_block = each.value
  target_vpc_subnet_id   = var.associated_subnet_ids[0]

  depends_on = [aws_ec2_client_vpn_network_association.this]
}
