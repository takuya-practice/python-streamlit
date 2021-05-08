## VPC ##
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

variable "ingress_ports" {
  type        = list(number)
  description = "list of ingress ports"
  default     = [8200, 8201]
}

resource "aws_security_group" "vault" {
  name        = "vault"
  description = "Ingress for Vault"
  vpc_id      = aws_vpc.main.id

  # dynamic "ingress" { 
  #   for_each = var.ingress_ports
  # のSyntaxはJavaでいう下記のSyntaxに相当する
  # Iterator<Map.Entry<Integer, Integer>> ingress = var.ingress_ports.entrySet().iterator();
  # ingress.key()
  # ingress.value()

  dynamic "ingress" {  # <---- localの名前を"ingress"と定義
    # for_each argumentに、LoopするObjectをAssign
    for_each = var.ingress_ports # <------ numberリストの変数をループする

    # The iterator argument (任意)は現在ループしているオブジェクトの名前。デフォルトではdynamic blockの"ingress"になります。
    iterator = port 

    # contentブロック内に、ループしながら作成するブロックのAttributesを定義する
    content { 
      # iteratorオブジェクトであるsettingには２つのAttributeがあり、keyはmap keyかlistのindex.（例：JavaのMap iteratorがkeyとvalueの２つのAttributeを持つのと似ている）
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}



variable "settings" {
  type = list(map(string))
  default = [
    {
      namespace = "aws:ec2:vpc"
      name = "VPCId"
      value = "vpc-xxxxxxxxxxxxxxxxx"
    },
    {
      namespace = "aws:ec2:vpc"
      name = "Subnets"
      value = "subnet-xxxxxxxxxxxxxxxxx"
    },
  ]
}

# mapの変数をloopする場合
resource "aws_elastic_beanstalk_environment" "tfenvtest" {
  name                = "tf-test-name"
  application         = "test"
  solution_stack_name = "64bit Amazon Linux 2018.03 v2.11.4 running Go 1.12.6"

  # dynamic "setting" { 
  #   for_each = var.settings
  # のSyntaxはJavaでいう下記のSyntaxに相当する
  # Iterator<Map.Entry<String, String>> setting = var.settings.entrySet().iterator(); 
  # setting.key()
  # setting.value()
  
  dynamic "setting" {
    for_each = var.settings
    
    content {
      # iteratorオブジェクトであるsettingには２つのAttributeがあり、keyはmap keyかlistのindex.（例：JavaのMap iteratorがkeyとvalueの２つのAttributeを持つのと似ている）
      # Map.Entry<String, String> entry = setting.next(); 
      # System.out.println("Key = " + entry.getKey() + ", Value = " + entry.getValue());
      namespace = setting.value["namespace"]
      name = setting.value["name"]
      value = setting.value["value"]
    }
  }
}



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