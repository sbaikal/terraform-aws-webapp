terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }

    extip = {
      source  = "petems/extip"
      version = "0.1.2"
    }
  }
}

provider "aws" {
  region = var.aws_region
}