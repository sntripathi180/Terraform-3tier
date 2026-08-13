resource "aws_route53_zone" "private" {
  name = var.domain_name

  vpc {
    vpc_id = var.vpc_id
  }

  tags = merge(var.tags, { Name = var.domain_name })
}

resource "aws_route53_record" "this" {
  for_each = var.records

  zone_id = aws_route53_zone.private.zone_id
  name    = "${each.key}.${var.domain_name}"
  type    = "CNAME"
  ttl     = 300
  records = [each.value]
}

resource "aws_route53_record" "a" {
  for_each = var.a_records

  zone_id = aws_route53_zone.private.zone_id
  name    = "${each.key}.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = [each.value]
}
