output "zone_id" {
  value = aws_route53_zone.private.zone_id
}

output "domain_name" {
  value = var.domain_name
}
