# -------------------------------------
# VPC
# -------------------------------------
resource "aws_vpc" "vpc" {
  cidr_block                       = var.vpc_cidr
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
# Subnet
# -------------------------------------
resource "aws_subnet" "front_public_subnets" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = length(var.vpc.front_public_subnets)
  cidr_block              = var.front_public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name    = "${var.project}-${var.env}-${keys(var.vpc.front_public_subnets)[count.index]}"
    Project = var.project
    Env     = var.env
    Type    = "public"
  }
}

resource "aws_subnet" "web_app_private_subnets" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = length(var.vpc.web_app_private_subnets)
  cidr_block              = var.web_app_private_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name    = "${var.project}-${var.env}-${keys(var.vpc.web_app_private_subnets)[count.index]}"
    Project = var.project
    Env     = var.env
    Type    = "private"
  }
}

resource "aws_subnet" "db_private_subnets" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = length(var.vpc.db_private_subnets)
  cidr_block              = var.db_private_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name    = "${var.project}-${var.env}-${keys(var.vpc.db_private_subnets)[count.index]}"
    Project = var.project
    Env     = var.env
    Type    = "private"
  }
}

# -------------------------------------
# Route Table
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
  subnet_id      = aws_subnet.front_public_subnets[0].id
  route_table_id = aws_route_table.front_public_rt.id
}
resource "aws_route_table_association" "front_public_rt_1c" {
  subnet_id      = aws_subnet.front_public_subnets[1].id
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
  subnet_id      = aws_subnet.web_app_private_subnets[0].id
  route_table_id = aws_route_table.web_app_private_rt.id
}
resource "aws_route_table_association" "web_app_private_rt_1c" {
  subnet_id      = aws_subnet.web_app_private_subnets[1].id
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
  subnet_id      = aws_subnet.db_private_subnets[0].id
  route_table_id = aws_route_table.db_private_rt.id
}
resource "aws_route_table_association" "db_private_rt_1c" {
  subnet_id      = aws_subnet.db_private_subnets[1].id
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

# -------------------------------------
# Nat Gateway
# -------------------------------------
# resource "aws_eip" "public_ngw_1a_eip" {
#   vpc = true

#   tags = {
#     Name    = "${var.project}-${var.env}-public-ngw-1a-eip"
#     Project = var.project
#     Env     = var.env
#     Type    = "public"
#   }
# }

# resource "aws_nat_gateway" "public_ngw_1a" {
#   allocation_id     = aws_eip.public_ngw_1a_eip.id
#   subnet_id         = aws_subnet.front_public_subnets[0].id
#   connectivity_type = "public"

#   tags = {
#     Name    = "${var.project}-${var.env}-public-ngw-1a"
#     Project = var.project
#     Env     = var.env
#     Type    = "public"
#   }

#   depends_on = [aws_internet_gateway.igw]
# }

# resource "aws_route" "web_app_private_rt_ngw_route" {
#   route_table_id         = aws_route_table.web_app_private_rt.id
#   destination_cidr_block = "0.0.0.0/0"
#   gateway_id             = aws_nat_gateway.public_ngw_1a.id
# }

