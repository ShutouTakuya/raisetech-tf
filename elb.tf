# -------------------------------------
# ALB
# -------------------------------------
# external alb
resource "aws_lb" "external_alb" {
  name               = "${var.project}-${var.env}-external-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups = [
    aws_security_group.external_alb_sg.id
  ]
  subnets = [
    aws_subnet.front_public_subnets[0].id,
    aws_subnet.front_public_subnets[1].id
  ]
}

# external alb listener
resource "aws_lb_listener" "external_alb_listener_http" {
  load_balancer_arn = aws_lb.external_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "redirect"
    target_group_arn = aws_lb_target_group.external_alb_target_group.arn

    redirect {
      port        = 443
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "external_alb_listener_https" {
  load_balancer_arn = aws_lb.external_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.tokyo_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.external_alb_target_group.arn
  }
}

# internal alb
# resource "aws_lb" "internal_alb" {
#   name               = "${var.project}-${var.env}-internal-alb"
#   internal           = true
#   load_balancer_type = "application"
#   security_groups = [
#     aws_security_group.internal_alb_sg.id
#   ]
#   subnets = [
#     aws_subnet.web_app_private_subnets[0].id,
#     aws_subnet.web_app_private_subnets[1].id
#   ]
# }

# internal alb listener
# resource "aws_lb_listener" "internal_alb_listener_http" {
#   load_balancer_arn = aws_lb.internal_alb.arn
#   port              = 80
#   protocol          = "HTTP"

#   default_action {
#     type             = "redirect"
#     target_group_arn = aws_lb_target_group.internal_alb_target_group.arn

#     redirect {
#       port        = "443"
#       protocol    = "HTTPS"
#       status_code = "HTTP_301"
#     }
#   }
# }

# resource "aws_lb_listener" "internal_alb_listener_https" {
#   load_balancer_arn = aws_lb.internal_alb.arn
#   port              = 443
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-2016-08"
#   certificate_arn   = aws_acm_certificate.tokyo_cert.arn

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.internal_alb_target_group.arn
#   }
# }

# -------------------------------------
# Target Group
# -------------------------------------
# external alb target group
resource "aws_lb_target_group" "external_alb_target_group" {
  name     = "${var.project}-${var.env}-external-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

  tags = {
    Name    = "${var.project}-${var.env}-external-alb-tg"
    Project = var.project
    Env     = var.env
  }
}

# internal alb target group
# resource "aws_lb_target_group" "internal_alb_target_group" {
#   name     = "${var.project}-${var.env}-internal-alb-tg"
#   port     = 3000
#   protocol = "HTTP"
#   vpc_id   = aws_vpc.vpc.id

#   tags = {
#     Name    = "${var.project}-${var.env}-internal-alb-tg"
#     Project = var.project
#     Env     = var.env
#   }
# }
