# -------------------------------------
# key pair
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

# -------------------------------------
# ssm parameter store
# -------------------------------------
resource "aws_ssm_parameter" "db_host" {
  name  = "/${var.project}/${var.env}/app/MYSQL_HOST"
  type  = "string"
  value = aws_db_instance.mysql_standalone.address
}
resource "aws_ssm_parameter" "db_port" {
  name  = "/${var.project}/${var.env}/app/MYSQL_PORT"
  type  = "string"
  value = aws_db_instance.mysql_standalone.port
}
resource "aws_ssm_parameter" "db_name" {
  name  = "/${var.project}/${var.env}/app/MYSQL_DATABASE"
  type  = "string"
  value = aws_db_instance.mysql_standalone.name
}
resource "aws_ssm_parameter" "db_username" {
  name  = "/${var.project}/${var.env}/app/MYSQL_USERNAME"
  type  = "SecureString"
  value = aws_db_instance.mysql_standalone.username
}
resource "aws_ssm_parameter" "db_password" {
  name  = "/${var.project}/${var.env}/app/MYSQL_PASSWORD"
  type  = "SecureString"
  value = aws_db_instance.mysql_standalone.password
}

# -------------------------------------
# ec2 instance
# -------------------------------------
resource "aws_instance" "app_server" {
  ami                  = data.aws_ami.app.id
  instance_type        = "t2.micro"
  subnet_id            = aws_subnet.web_app_private_subnet_1a.id
  iam_instance_profile = aws_iam_instance_profile.app_ec2_profile.name
  vpc_security_group_ids = [
    aws_security_group.app_sg.id,
    aws_security_group.opmng_sg.id
  ]
  key_name = aws_key_pair.keypair.key_name

  tags = {
    Name    = "${var.project}-${var.env}-app-server-1a"
    Project = var.project
    Env     = var.env
    Type    = "app"
  }
}