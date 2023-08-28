data "terraform_remote_state" "base" {
  backend = "s3"
  config = {
    bucket = "meteor-challenge-terraform-state"
    key    = "base.tfstate"
    region = "us-east-1"
  }
}

data "aws_vpc" "default" {
  default = true
}
