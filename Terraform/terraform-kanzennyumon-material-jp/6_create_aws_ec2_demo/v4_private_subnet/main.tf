###############
## Variables ##
###############
# variable "aws_access_key" {}
# variable "aws_secret_key" {}
variable "aws_region" {
  default = "ap-northeast-1"
}
variable "aws_profile" {}
variable "amis" {
  type = "map"
  default = {
    us-east-1 = "ami-13be557e"
    us-west-2 = "ami-06b94666"
    ap-northeast-1 = "ami-034968955444c1fd9"
  }
}
variable "subnet_id" {}

###############
## TF Version ##
###############
terraform {
  required_version = ">= 0.12.28"
}

###############
## Provider ##
###############
provider "aws" {
    # access_key = var.aws_access_key
    # secret_key = var.aws_secret_key
    region = var.aws_region
    profile = var.aws_profile
    version = "~> 2.49"
}

###############
## Main ##
###############
# Ref: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
resource "aws_instance" "example" {
  ami           = lookup(var.amis, var.aws_region)
  instance_type = "t2.micro"
  subnet_id = var.subnet_id

  tags = {
    terraform = "true"
  }
}
