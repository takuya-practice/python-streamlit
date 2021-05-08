## 最低限必要なAWS Config (AWS CLIで”aws config”を実行して、Region、Access Keyなどを設定するのと同じ) ##
variable "aws_region" {
  default = "ap-northeast-1"
}
variable "aws_profile" {
  # type = string
  default = "aws-demo"
  # description = "AWS CLI's profile"
}

# modules/ec2/main.tf はinstance_typeという変数のInputが必要
variable "root_level_instance_type" {}
