# -------------------------------------
# Route53
# -------------------------------------
resource "aws_route53_zone" "route53_zone" {
  name          = var.domain
  force_destroy = true

  tags = {
    Name    = "${var.project}-${var.env}-domain"
    Project = var.project
    Env     = var.env
  }
}

resource "aws_route53_record" "route53_record" {
  zone_id = aws_route53_zone.route53_zone.id
  name    = var.domain
  type    = "A"

  alias {
    name                   = aws_lb.external_alb.dns_name
    zone_id                = aws_lb.external_alb.zone_id
    evaluate_target_health = true
  }
}
