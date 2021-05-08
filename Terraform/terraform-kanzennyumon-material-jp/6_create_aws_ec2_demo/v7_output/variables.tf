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
    us-east-1      = "ami-13be557e"
    us-west-2      = "ami-06b94666"
    ap-northeast-1 = "ami-034968955444c1fd9"
  }
}
variable "subnet_id" {}
variable "instance_type" {}