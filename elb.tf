# -------------------------------------
# ALB
# -------------------------------------
# internet alb
resource "aws_lb" "internet_alb" {
  name               = "${var.project}-${var.env}-internet-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups = [
    aws_security_group.internet_alb_sg.id
  ]
  subnets = [
    aws_subnet.front_public_subnets[0].id,
    aws_subnet.front_public_subnets[1].id
  ]
}
# internet alb listener
resource "aws_lb_listener" "internet_alb_listener_http" {
  load_balancer_arn = aws_lb.internet_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "redirect"
    target_group_arn = aws_lb_target_group.internet_alb_target_group.arn

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# internal alb
resource "aws_lb" "internal_alb" {
  name               = "${var.project}-${var.env}-internal-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups = [
    aws_security_group.internal_alb_sg.id
  ]
  subnets = [
    aws_subnet.web_app_private_subnets[0].id,
    aws_subnet.web_app_private_subnets[1].id
  ]
}
# internal alb listener
resource "aws_lb_listener" "internal_alb_listener_http" {
  load_balancer_arn = aws_lb.internal_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "redirect"
    target_group_arn = aws_lb_target_group.internal_alb_target_group.arn

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# -------------------------------------
# Target Group
# -------------------------------------
# internet alb target group
resource "aws_lb_target_group" "internet_alb_target_group" {
  name     = "${var.project}-${var.env}-internet-alb-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

  tags = {
    Name    = "${var.project}-${var.env}-internet-alb-tg"
    Project = var.project
    Env     = var.env
  }
}

# internal alb target group
resource "aws_lb_target_group" "internal_alb_target_group" {
  name     = "${var.project}-${var.env}-internal-alb-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

  tags = {
    Name    = "${var.project}-${var.env}-internal-alb-tg"
    Project = var.project
    Env     = var.env
  }
}