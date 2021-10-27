# -------------------------------------
# Keypair
# -------------------------------------
resource "aws_key_pair" "keypair" {
  key_name   = "${var.project}-${var.env}-keypair"
  public_key = file("./keys/raisetech_tf_key.pub")

  tags = {
    Name    = "${var.project}-${var.env}-keypair"
    Project = var.project
    Env     = var.env
  }
}

# # -------------------------------------
# # SSM Parameter Store
# # -------------------------------------
# resource "aws_ssm_parameter" "db_host" {
#   name  = "/${var.project}/${var.env}/app/MYSQL_HOST"
#   type  = "string"
#   value = aws_db_instance.mysql_standalone.address
# }
# resource "aws_ssm_parameter" "db_port" {
#   name  = "/${var.project}/${var.env}/app/MYSQL_PORT"
#   type  = "string"
#   value = aws_db_instance.mysql_standalone.port
# }
# resource "aws_ssm_parameter" "db_name" {
#   name  = "/${var.project}/${var.env}/app/MYSQL_DATABASE"
#   type  = "string"
#   value = aws_db_instance.mysql_standalone.name
# }
# resource "aws_ssm_parameter" "db_username" {
#   name  = "/${var.project}/${var.env}/app/MYSQL_USERNAME"
#   type  = "SecureString"
#   value = aws_db_instance.mysql_standalone.username
# }
# resource "aws_ssm_parameter" "db_password" {
#   name  = "/${var.project}/${var.env}/app/MYSQL_PASSWORD"
#   type  = "SecureString"
#   value = aws_db_instance.mysql_standalone.password
# }

# # -------------------------------------
# # EC2 Instance
# # -------------------------------------
# resource "aws_instance" "ap_server" {
#   ami                  = data.aws_ami.app.id
#   instance_type        = "t2.micro"
#   subnet_id            = aws_subnet.web_app_private_subnet_1a.id
#   iam_instance_profile = aws_iam_instance_profile.app_ec2_profile.name
#   vpc_security_group_ids = [
#     aws_security_group.app_sg.id,
#     aws_security_group.opmng_sg.id
#   ]
#   key_name = aws_key_pair.keypair.key_name

#   tags = {
#     Name    = "${var.project}-${var.env}-ap-server-1a"
#     Project = var.project
#     Env     = var.env
#     Type    = "app"
#   }
# }

# -------------------------------------
# Launch Template
# -------------------------------------
# Webサーバー用の起動テンプレート
resource "aws_launch_template" "web_server_lt" {
  update_default_version = true
  name                   = "${var.project}-${var.env}-web-server-lt"
  image_id               = data.aws_ami.web_server.image_id
  key_name               = aws_key_pair.keypair.key_name

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name    = "${var.project}-${var.env}-web-server-from-asg"
      Project = var.project
      Env     = var.env
      Type    = "web"
    }
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups = [
      aws_security_group.web_sg.id
    ]
    delete_on_termination = true
  }
}

# APサーバー用の起動テンプレート
resource "aws_launch_template" "ap_server_lt" {
  update_default_version = true
  name                   = "${var.project}-${var.env}-ap-server-lt"
  image_id               = data.aws_ami.ap_server.image_id
  key_name               = aws_key_pair.keypair.key_name

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name    = "${var.project}-${var.env}-ap-server-from-asg"
      Project = var.project
      Env     = var.env
      Type    = "app"
    }
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups = [
      aws_security_group.app_sg.id,
      aws_security_group.opmng_sg.id
    ]
    delete_on_termination = true
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.app_ec2_profile.name
  }
}

# -------------------------------------
# Auto Scaring Group
# -------------------------------------
# Webサーバー用のAuto Scaring Group
resource "aws_autoscaling_group" "web_server_asg" {
  name                      = "${var.project}-${var.env}-asg-for-web-server"
  max_size                  = 6
  min_size                  = 2
  desired_capacity          = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  vpc_zone_identifier = [
    aws_subnet.web_app_private_subnets[0].id,
    aws_subnet.web_app_private_subnets[1].id
  ]
  target_group_arns = [aws_lb_target_group.external_alb_target_group.arn]

  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.web_server_lt.id
        version            = "$Latest"
      }
      override {
        instance_type = var.default_instance_type
      }
    }
  }
}

# APサーバー用のAuto Scaring Group
resource "aws_autoscaling_group" "ap_server_asg" {
  name                      = "${var.project}-${var.env}-asg-for-ap-server"
  max_size                  = 4
  min_size                  = 2
  desired_capacity          = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  vpc_zone_identifier = [
    aws_subnet.web_app_private_subnets[0].id,
    aws_subnet.web_app_private_subnets[1].id
  ]
  target_group_arns = [aws_lb_target_group.internal_alb_target_group.arn]

  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.ap_server_lt.id
        version            = "$Latest"
      }
      override {
        instance_type = var.default_instance_type
      }
    }
  }
}

# -------------------------------------
# Nat Gateway
# -------------------------------------
resource "aws_eip" "public_ngw_1a_eip" {
  vpc = true

  tags = {
    Name    = "${var.project}-${var.env}-public-ngw-1a-eip"
    Project = var.project
    Env     = var.env
    Type    = "public"
  }
}

resource "aws_nat_gateway" "public_ngw_1a" {
  allocation_id     = aws_eip.public_ngw_1a_eip.id
  subnet_id         = aws_subnet.front_public_subnets[0].id
  connectivity_type = "public"

  tags = {
    Name    = "${var.project}-${var.env}-public-ngw-1a"
    Project = var.project
    Env     = var.env
    Type    = "public"
  }

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route" "web_app_private_rt_ngw_route" {
  route_table_id         = aws_route_table.web_app_private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.public_ngw_1a.id
}
