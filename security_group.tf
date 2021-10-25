# -------------------------------------
# Security Group
# -------------------------------------
# bastion security group
locals {
  current_ip = chomp(data.http.ifconfig.body)
  my_ip      = (var.my_ip == null) ? "${local.current_ip}/32" : var.my_ip
}
resource "aws_security_group" "bastion_sg" {
  name        = "${var.project}-${var.env}-bastion-sg"
  description = "SSH from mylaptop"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name    = "${var.project}-${var.env}-bastion-sg"
    Project = var.project
    Env     = var.env
  }
}
resource "aws_security_group_rule" "bastion_sg_ingress_ssh" {
  security_group_id = aws_security_group.bastion_sg.id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [local.my_ip]
}

# opmng security group
resource "aws_security_group" "opmng_sg" {
  name        = "${var.project}-${var.env}-opmng-sg"
  description = "HTTP and HTTPS, TCP3000 and SSH from"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name    = "${var.project}-${var.env}-opmng-sg"
    Project = var.project
    Env     = var.env
  }
}
resource "aws_security_group_rule" "opmng_sg_ingress_ssh" {
  security_group_id        = aws_security_group.opmng_sg.id
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion_sg.id
}
resource "aws_security_group_rule" "opmng_sg_ingress_tcp3000" {
  security_group_id        = aws_security_group.opmng_sg.id
  type                     = "ingress"
  from_port                = 3000
  to_port                  = 3000
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion_sg.id
}
resource "aws_security_group_rule" "opmng_sg_egress_http" {
  security_group_id        = aws_security_group.opmng_sg.id
  type                     = "egress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion_sg.id
}
resource "aws_security_group_rule" "opmng_sg_egress_https" {
  security_group_id        = aws_security_group.opmng_sg.id
  type                     = "egress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion_sg.id
}

# internet alb security group
resource "aws_security_group" "internet_alb_sg" {
  name        = "${var.project}-${var.env}-internet-alb-sg"
  description = "HTTP and HTTPS from anywhere"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name    = "${var.project}-${var.env}-internet-alb-sg"
    Project = var.project
    Env     = var.env
  }
}
resource "aws_security_group_rule" "internet_alb_sg_ingress_http" {
  security_group_id = aws_security_group.internet_alb_sg.id
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}
resource "aws_security_group_rule" "internet_alb_sg_ingress_https" {
  security_group_id = aws_security_group.internet_alb_sg.id
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

# web security group
resource "aws_security_group" "web_sg" {
  name        = "${var.project}-${var.env}-web-sg"
  description = "HTTP and HTTPS from Internet ALB Security Group"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name    = "${var.project}-${var.env}-web-sg"
    Project = var.project
    Env     = var.env
  }
}
resource "aws_security_group_rule" "web_sg_ingress_http" {
  security_group_id        = aws_security_group.web_sg.id
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.internet_alb_sg.id
}
resource "aws_security_group_rule" "web_sg_ingress_https" {
  security_group_id        = aws_security_group.web_sg.id
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.internet_alb_sg.id
}
resource "aws_security_group_rule" "web_sg_egress_tcp3000" {
  security_group_id        = aws_security_group.web_sg.id
  type                     = "egress"
  from_port                = 3000
  to_port                  = 3000
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.internal_alb_sg.id
}

# internal alb security group
resource "aws_security_group" "internal_alb_sg" {
  name        = "${var.project}-${var.env}-internal-alb-sg"
  description = "TCP3000 from Web Security Group"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name    = "${var.project}-${var.env}-internal-alb-sg"
    Project = var.project
    Env     = var.env
  }
}
resource "aws_security_group_rule" "internal_alb_sg_ingress_http" {
  security_group_id        = aws_security_group.internal_alb_sg.id
  type                     = "ingress"
  from_port                = 3000
  to_port                  = 3000
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.web_sg.id
}

# app security group
resource "aws_security_group" "app_sg" {
  name        = "${var.project}-${var.env}-app-sg"
  description = "TCP3000 from ALB Security Group for Internal"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name    = "${var.project}-${var.env}-app-sg"
    Project = var.project
    Env     = var.env
  }
}
resource "aws_security_group_rule" "app_sg_ingress_tcp3000" {
  security_group_id        = aws_security_group.app_sg.id
  type                     = "ingress"
  from_port                = 3000
  to_port                  = 3000
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.internal_alb_sg.id
}
resource "aws_security_group_rule" "app_sg_egress_http" {
  security_group_id = aws_security_group.app_sg.id
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  prefix_list_ids   = [data.aws_prefix_list.s3_pl.id]
}
resource "aws_security_group_rule" "app_sg_egress_https" {
  security_group_id = aws_security_group.app_sg.id
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  prefix_list_ids   = [data.aws_prefix_list.s3_pl.id]
}
resource "aws_security_group_rule" "app_sg_egress_3306" {
  security_group_id        = aws_security_group.app_sg.id
  type                     = "egress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.db_sg.id
}

# db security group
resource "aws_security_group" "db_sg" {
  name        = "${var.project}-${var.env}-db-sg"
  description = "3306 from App Security Group"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name    = "${var.project}-${var.env}-db-sg"
    Project = var.project
    Env     = var.env
  }
}
resource "aws_security_group_rule" "db_sg_ingress_3306" {
  security_group_id        = aws_security_group.db_sg.id
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.app_sg.id
}