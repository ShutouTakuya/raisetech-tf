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
  backend "s3" {
    bucket  = "raisetech-tfstate-bucket-1019"
    key     = "raisetech-dev.tfstate"
    region  = "ap-northeast-1"
    profile = "terraform-shutou"
  }
}

# -------------------------------------
# provider
# -------------------------------------
provider "aws" {
  profile = var.profile
  region  = var.region
}

provider "http" {
  version = "~> 1.1"
}