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
}


# data {} blockを使って定義し、最新のAmazon-linux-2のAMIのIDをFetchする
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners = ["amazon"]

  # filterを使ってリソースを絞り込む
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}


# ローカル変数の値をアクセスする
resource "aws_instance" "web" {
  instance_type = "t2.micro"
  ami           = data.aws_ami.amazon_linux_2.id # <-----data blockの値をアクセス
}

# resource "aws_instance" "web"で作成されたEC2のObjectをRuntime時に、Filterを使ってFetchも可能
data "aws_instance" "web" {
  filter {
    name   = "image-id"
    values = [data.aws_ami.amazon_linux_2.id]
  }
}

# 違うModuleで作成されたAWSリソースをRuntime時に、Filterを使って取得
output "ec2_from_fetched_ami" {
  value = data.aws_instance.web.id
}

output "ec2_from_aws_instance_resource" {
  value = aws_instance.web.id
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