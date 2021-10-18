# -------------------------------------
# terraform configuration
# -------------------------------------
terraform {
  required_version = ">=0.13"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>3.0"
    }
  }
}

# -------------------------------------
# provider
# -------------------------------------
provider "aws" {
  profile = var.profile
  region  = "ap-northeast-1"
}

provider "http" {
  version = "~> 1.1"
}