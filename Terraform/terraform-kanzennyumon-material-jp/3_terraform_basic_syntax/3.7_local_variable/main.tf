# variableブロックを使って、image_idという変数の名前を定義する
variable "image_id" {
  type = string # [string, number, bool]
  description = "The id of the machine image (AMI) to use for the server." # 任意
  default = "ami-abc123" # 任意のDefault値
  # sensitive = true # 任意, これを設定すると、Terraform planやapplyコマンドのアウトプットに値が表示されなくなる
}

variable "amis" {
  type = map
  default = {
    us-east-1 = "ami-13be557e"
    us-west-2 = "ami-06b94666"
    ap-northeast-1 = "ami-034968955444c1fd9"
  }
}

# local {} blockを使って定義、この変数のScopeは同じmodule内（同じフォルダー内）
locals {
  image_id = "ami-034968955444c1fd9"
  ami_id = "fdfsdsd"
}

# ローカル変数の値をアクセスする
resource "aws_instance" "web" {
  instance_type = "t2.micro"
  ami           = local.image_id  # <-----ローカル変数image_idの値をアクセス
}


# output blockを使って、"instance_ip_address"というアウトプット変数を定義
output "instance_ip_address" {
  value = aws_instance.web.private_ip
  description = "The private IP address of the main server instance."
  # sensitive = true # 任意, これを設定すると、Terraform planやapplyコマンドのアウトプットに値が表示されなくなる
}

# # child moduleのアウトプットを module.<MODULE NAME>.<OUTPUT NAME>のSyntaxでアクセス
# output "ec2_id" {
#   value = module.ec2.id　# <----- ec2というmoduleのidというアウトプット変数の値をアクセス
# }



## AWS Config ##
variable "aws_region" {
  default = "ap-northeast-1"
}
variable "aws_profile" {
  # type = string
  default = "aws-demo"
  # description = "AWS CLI's profile"
}
provider "aws" {
    # access_key = var.aws_access_key
    # secret_key = var.aws_secret_key
    region = var.aws_region
    profile = var.aws_profile
    version = "~> 2.49"
}