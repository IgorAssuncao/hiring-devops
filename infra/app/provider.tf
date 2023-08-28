terraform {
  backend "s3" {
    bucket = "meteor-challenge-terraform-state"
    key    = "app.tfstate"
    region = "us-east-1"
    // encrypt        = true
    // dynamodb_table = "meteor-challenge-terraform-state"
  }

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
