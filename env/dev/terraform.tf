terraform {
  required_version = "~> 1.8.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.50.0"
    }
  }

  backend "s3" {
    bucket = "terraform-swarm-aws-ec2-instances"
    key    = "states/release-tfstate"
    region = "ap-southeast-1"
  }
}