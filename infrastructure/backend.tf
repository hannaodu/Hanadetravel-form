
terraform {
  backend "s3" {
    bucket = "hanadetravelease-terraform-state-2024"
    key    = "hanadetravelease-contact/terraform.tfstate"
    region = "eu-west-2"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
