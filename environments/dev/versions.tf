terraform {
  required_version = ">= 1.7.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }


  backend "s3" {
    bucket       = "terrafrom-s3-backend-545620235238-ap-south-1-an"
    key          = "myapp/production/tfstate"
    region       = "ap-south-1"
    use_lockfile = true
  }


}


provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.tags
  }
}