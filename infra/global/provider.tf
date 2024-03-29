terraform {
  required_version = "1.4.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.13.1"
    }
  }
}

provider "aws" {
  default_tags {
    tags = {
      ManagedBy    = "Terraform"
      Name         = "Meteor-challenge"
      Organization = "Meteor"
    }
  }
}
