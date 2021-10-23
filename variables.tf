# -------------------------------------
# Common
# -------------------------------------
variable "profile" {
  type = string
}
variable "project" {
  type = string
}
variable "env" {
  type = string
}
variable "region" {
  type = string
}
variable "availability_zones" {
  type = list(string)
}
variable "my_ip" {
  default = null
}

# -------------------------------------
# Network
# -------------------------------------
variable "vpc_cidr" {
  type = string
}
variable "front_public_subnet_cidrs" {
  type = list(string)
}
variable "web_app_private_subnet_cidrs" {
  type = list(string)
}
variable "db_private_subnet_cidrs" {
  type = list(string)
}

variable "vpc" {
  default = {
    front_public_subnets = {
      front-public-subnet-1a = {}
      front-public-subnet-1c = {}
    }
    web_app_private_subnets = {
      web-app-private-subnet-1a = {}
      web-app-private-subnet-1c = {}
    }
    db_private_subnets = {
      db-private-subnet-1a = {}
      db-private-subnet-1c = {}
    }
  }
}