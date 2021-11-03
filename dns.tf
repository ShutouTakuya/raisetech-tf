# # -------------------------------------
# # Route53
# # -------------------------------------
# resource "aws_route53_zone" "public_route53_zone" {
#   name          = var.domain
#   force_destroy = true

#   tags = {
#     Name    = "${var.project}-${var.env}-domain"
#     Project = var.project
#     Env     = var.env
#   }
# }

# resource "aws_route53_record" "public_route53_record" {
#   zone_id = aws_route53_zone.public_route53_zone.zone_id
#   name    = "www.${var.domain}"
#   type    = "A"

#   alias {
#     name                   = aws_lb.external_alb.dns_name
#     zone_id                = aws_lb.external_alb.zone_id
#     evaluate_target_health = true
#   }
# }

# resource "aws_route53_zone" "private_route53_zone" {
#   name = "internal-alb"

#   vpc {
#     vpc_id = aws_vpc.vpc.id
#   }
# }
