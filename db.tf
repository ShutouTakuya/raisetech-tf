# -------------------------------------
# rds parameter group
# -------------------------------------
resource "aws_db_parameter_group" "mysql_standalone_parametergroup" {
  name   = "${var.project}-${var.env}-mysql-standalone-parametergroup"
  family = "mysql8.0"

  parameter {
    name  = "character_set_database"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }
}

# -------------------------------------
# rds option group
# -------------------------------------
resource "aws_db_option_group" "mysql_standalone_optiongroup" {
  name                     = "${var.project}-${var.env}-mysql-standalone-optiongroup"
  option_group_description = "StandAlone option group for mysql"
  engine_name              = "mysql"
  major_engine_version     = "8.0"
}

# -------------------------------------
# rds subnet group
# -------------------------------------
resource "aws_db_subnet_group" "mysql_standalone_subnetgroup" {
  name = "${var.project}-${var.env}-mysql-standalone-subnetgroup"
  subnet_ids = [
    aws_subnet.db_private_subnet_1a.id,
    aws_subnet.db_private_subnet_1c.id
  ]

  tags = {
    Name    = "${var.project}-${var.env}-db-subnetgroup"
    Project = var.project
    Env     = var.env
  }
}

# -------------------------------------
# rds instance
# -------------------------------------
resource "random_string" "random_string_for_db_password" {
  length  = 16
  special = false
}

resource "aws_db_instance" "mysql_standalone" {
  identifier = "${var.project}-${var.env}-mysql-standalone"

  # othser settings
  name                = "raisetech"
  publicly_accessible = false
  port                = 3306
  multi_az            = true

  # engine
  engine         = "mysql"
  engine_version = "8.0"

  # storage and instance class
  instance_class        = "db.t2.micro"
  allocated_storage     = 20
  max_allocated_storage = 50
  storage_type          = "gp2"
  storage_encrypted     = false

  # db login
  username = "admin"
  password = random_string.random_string_for_db_password.result

  # groups
  parameter_group_name   = aws_db_parameter_group.mysql_standalone_parametergroup.name
  option_group_name      = aws_db_option_group.mysql_standalone_optiongroup.name
  db_subnet_group_name   = aws_db_subnet_group.mysql_standalone_subnetgroup.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]

  # backup and maintenance
  backup_window              = "04:00-05:00" # メンテナンス前にバックアップを実行
  backup_retention_period    = 7
  maintenance_window         = "Mon:05:00-Mon:08:00" # バックアップ後にメンテナンスを実行
  auto_minor_version_upgrade = false

  # delete protection and snapshot(削除保護無効化)
  deletion_protection = false
  skip_final_snapshot = true
  apply_immediately   = true

  tags = {
    Name    = "${var.project}-${var.env}-rds"
    Project = var.project
    Env     = var.env
  }
}