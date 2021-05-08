###############
## Main ##
###############
# Ref: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
resource "aws_instance" "example" {
  ami           = lookup(var.amis, var.aws_region)
  instance_type = var.instance_type
  subnet_id     = aws_subnet.main.id

  tags = {
    terraform = "true"
  }
}

# VPC #
resource "aws_vpc" "main" {
  cidr_block = var.cidr_block
}


# subnet #
resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.subnet_cidr_block

  tags = {
    Name = "Main"
  }
}