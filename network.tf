# -------------------------------------
# vpc
# -------------------------------------
resource "aws_vpc" "vpc" {
  cidr_block                       = "20.0.0.0/16"
  instance_tenancy                 = "default"
  enable_dns_support               = true
  enable_dns_hostnames             = true
  assign_generated_ipv6_cidr_block = false

  tags = {
    Name    = "${var.project}-${var.env}-vpc"
    Project = var.project
    Env     = var.env
  }
}

# -------------------------------------
# subnet
# -------------------------------------
# front public subnet
resource "aws_subnet" "front_public_subnet_1a" {
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = "ap-northeast-1a"
  cidr_block              = "20.0.0.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name    = "${var.project}-${var.env}-front-public-subnet-1a"
    Project = var.project
    Env     = var.env
    Type    = "public"
  }
}
resource "aws_subnet" "front_public_subnet_1c" {
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = "ap-northeast-1c"
  cidr_block              = "20.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name    = "${var.project}-${var.env}-front-public-subnet-1c"
    Project = var.project
    Env     = var.env
    Type    = "public"
  }
}

# web app private subnet
resource "aws_subnet" "web_app_private_subnet_1a" {
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = "ap-northeast-1a"
  cidr_block              = "20.0.20.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name    = "${var.project}-${var.env}-web-app-private-subnet-1a"
    Project = var.project
    Env     = var.env
    Type    = "private"
  }
}
resource "aws_subnet" "web_app_private_subnet_1c" {
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = "ap-northeast-1c"
  cidr_block              = "20.0.21.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name    = "${var.project}-${var.env}-web-app-private-subnet-1c"
    Project = var.project
    Env     = var.env
    Type    = "private"
  }
}

# db private subnet
resource "aws_subnet" "db_private_subnet_1a" {
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = "ap-northeast-1a"
  cidr_block              = "20.0.40.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name    = "${var.project}-${var.env}-db-private-subnet-1a"
    Project = var.project
    Env     = var.env
    Type    = "private"
  }
}
resource "aws_subnet" "db_private_subnet_1c" {
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = "ap-northeast-1c"
  cidr_block              = "20.0.41.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name    = "${var.project}-${var.env}-db-private-subnet-1c"
    Project = var.project
    Env     = var.env
    Type    = "private"
  }
}

# -------------------------------------
# route table
# -------------------------------------
# front public route table
resource "aws_route_table" "front_public_rt" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name    = "${var.project}-${var.env}-front-public-rt"
    Project = var.project
    Env     = var.env
    Type    = "public"
  }
}
resource "aws_route_table_association" "front_public_rt_1a" {
  subnet_id      = aws_subnet.front_public_subnet_1a.id
  route_table_id = aws_route_table.front_public_rt.id
}
resource "aws_route_table_association" "front_public_rt_1c" {
  subnet_id      = aws_subnet.front_public_subnet_1c.id
  route_table_id = aws_route_table.front_public_rt.id
}

# web app private route table
resource "aws_route_table" "web_app_private_rt" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name    = "${var.project}-${var.env}-web-app-private-rt"
    Project = var.project
    Env     = var.env
    Type    = "private"
  }
}
resource "aws_route_table_association" "web_app_private_rt_1a" {
  subnet_id      = aws_subnet.web_app_private_subnet_1a.id
  route_table_id = aws_route_table.web_app_private_rt.id
}
resource "aws_route_table_association" "web_app_private_rt_1c" {
  subnet_id      = aws_subnet.web_app_private_subnet_1c.id
  route_table_id = aws_route_table.web_app_private_rt.id
}

# db private route table
resource "aws_route_table" "db_private_rt" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name    = "${var.project}-${var.env}-db-private-rt"
    Project = var.project
    Env     = var.env
    Type    = "private"
  }
}
resource "aws_route_table_association" "db_private_rt_1a" {
  subnet_id      = aws_subnet.db_private_subnet_1a.id
  route_table_id = aws_route_table.db_private_rt.id
}
resource "aws_route_table_association" "db_private_rt_1c" {
  subnet_id      = aws_subnet.db_private_subnet_1c.id
  route_table_id = aws_route_table.db_private_rt.id
}

# -------------------------------------
# Internet Gateway
# -------------------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name    = "${var.project}-${var.env}-igw"
    Project = var.project
    Env     = var.env
  }
}

resource "aws_route" "front_public_rt_igw_route" {
  route_table_id         = aws_route_table.front_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}
