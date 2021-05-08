# "aws_instance"というタイプのresourceを定義し、 そのリソースに"web"というローカルネームをつける
resource "aws_instance" "web" { 

  # aws_instance resourceのArguments
  ami           = data.aws_ami.amazon_linux_2.id # <-----ローカル変数image_idの値をアクセス
  instance_type = var.module_instance_type
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_security_group" "vault" {
  name        = "webserver-security-group"
  description = "Ingress for HTTP and HTTPS traffic"
  vpc_id      = aws_vpc.main.id

  # dynamic "ingress" { 
  #   for_each = var.ingress_ports
  # のSyntaxはJavaでいう下記のSyntaxに相当する
  # Iterator<Map.Entry<String, String>> ingress = var.ingress_ports.entrySet().iterator();
  
  dynamic "ingress" {  # <---- localの名前を"ingress"と定義
    # for_each argumentに、LoopするObjectをAssign
    for_each = var.security_group_ingress_ports # <------ numberリストの変数をループする

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