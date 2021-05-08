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
