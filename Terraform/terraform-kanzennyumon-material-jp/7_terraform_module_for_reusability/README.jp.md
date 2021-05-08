# 7. (Intermediate) Terraform Moduleを使ってコードを再利用しよう

Refs:
- https://learn.hashicorp.com/tutorials/terraform/module?in=terraform/modules
- https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/2.21.0
- https://www.terraform.io/docs/configuration/blocks/modules/index.html s
- local module and accessing child module: https://www.terraform.io/docs/configuration/blocks/modules/syntax.html#calling-a-child-module
- separate dev and prod environments by creating separate dirs: https://learn.hashicorp.com/tutorials/terraform/organize-configuration?in=terraform/modules#separate-states
- module creation by infra components: https://learn.hashicorp.com/tutorials/terraform/pattern-module-creation?in=terraform/modules



> Modules are containers for multiple resources that are used together. A module consists of a collection of .tf and/or .tf.json files kept together in a directory

Moduleは複数のResourceブロックの集合体で、複数の.tfが１つのフォルダーに存在する。


> Modules are the main way to package and reuse resource configurations with Terraform

Moduleを使うことで、似通ったシナリオで使われるResourceをバンドル化して再利用可能になる。

Module sourceはlocal, terraform registry, git,などのOptionがあります。



# 7.1 一般的なModule structureの解剖
- https://www.terraform.io/docs/modules/structure.html

Modularizeしたい.tfコードを`modules/`内に作成。
```sh
$ tree complete-module/
.
├── README.md
├── main.tf # <----- ここから、例えばmodules/ec2のコードのファイルPathを指定してコードを再利用できる
├── variables.tf
├── outputs.tf
├── ...
├── modules/
│   ├── ec2/
│   │   ├── README.md
│   │   ├── variables.tf
│   │   ├── main.tf
│   │   ├── outputs.tf
│   ├── vpc/
│   ├── .../
```



# 7.2 local modulesを使ってみよう

[main.tf](main.tf)
```sh
# Moduleを使う場合は、ResourceでなくModuleブロックを定義する
module "webserver" {
  # 必ず必要なArg。PathはローカルファイルPathでもネット上のリンクでもOK
  source = "./modules/ec2" # <------ local moduleの場合

  # modules/ec2/main.tf はinstance_typeという変数のInputが必要
  instance_type = var.instance_type
}
```

[modules/ec2/main.tf](modules/ec2/main.tf)で、再利用可能な色々なResourceを定義する（VPC, EC2, セキュリティグループなど）
```sh
# "aws_instance"というタイプのresourceを定義し、 そのリソースに"web"というローカルネームをつける
resource "aws_instance" "web" { 

  # aws_instance resourceのArguments
  ami           = data.aws_ami.amazon_linux_2.id # <-----ローカル変数image_idの値をアクセス
  instance_type = var.instance_type
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
```


`terraform init`と`terraform apply` をすると、`modules/ec2/main.tf`で定義されたVPC, EC2, Security groupリソースが作成されるのがわかる
```sh
Terraform will perform the following actions:

  # module.webserver.aws_instance.web will be created
  + resource "aws_instance" "web" {
      + ami                          = "ami-0e1109ab72ed218cb"
      + arn                          = (known after apply)
      + associate_public_ip_address  = (known after apply)
      + availability_zone            = (known after apply)
      + cpu_core_count               = (known after apply)
      + cpu_threads_per_core         = (known after apply)
      + get_password_data            = false
      + host_id                      = (known after apply)
      + id                           = (known after apply)
      + instance_state               = (known after apply)
      + instance_type                = "t2.micro"
      + ipv6_address_count           = (known after apply)
      + ipv6_addresses               = (known after apply)
      + key_name                     = (known after apply)
      + network_interface_id         = (known after apply)
      + outpost_arn                  = (known after apply)
      + password_data                = (known after apply)
      + placement_group              = (known after apply)
      + primary_network_interface_id = (known after apply)
      + private_dns                  = (known after apply)
      + private_ip                   = (known after apply)
      + public_dns                   = (known after apply)
      + public_ip                    = (known after apply)
      + security_groups              = (known after apply)
      + source_dest_check            = true
      + subnet_id                    = (known after apply)
      + tenancy                      = (known after apply)
      + volume_tags                  = (known after apply)
      + vpc_security_group_ids       = (known after apply)

      + ebs_block_device {
          + delete_on_termination = (known after apply)
          + device_name           = (known after apply)
          + encrypted             = (known after apply)
          + iops                  = (known after apply)
          + kms_key_id            = (known after apply)
          + snapshot_id           = (known after apply)
          + volume_id             = (known after apply)
          + volume_size           = (known after apply)
          + volume_type           = (known after apply)
        }

      + ephemeral_block_device {
          + device_name  = (known after apply)
          + no_device    = (known after apply)
          + virtual_name = (known after apply)
        }

      + metadata_options {
          + http_endpoint               = (known after apply)
          + http_put_response_hop_limit = (known after apply)
          + http_tokens                 = (known after apply)
        }

      + network_interface {
          + delete_on_termination = (known after apply)
          + device_index          = (known after apply)
          + network_interface_id  = (known after apply)
        }

      + root_block_device {
          + delete_on_termination = (known after apply)
          + device_name           = (known after apply)
          + encrypted             = (known after apply)
          + iops                  = (known after apply)
          + kms_key_id            = (known after apply)
          + volume_id             = (known after apply)
          + volume_size           = (known after apply)
          + volume_type           = (known after apply)
        }
    }

  # module.webserver.aws_security_group.vault will be created
  + resource "aws_security_group" "vault" {
      + arn                    = (known after apply)
      + description            = "Ingress for HTTP and HTTPS traffic"
      + egress                 = (known after apply)
      + id                     = (known after apply)
      + ingress                = [
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = ""
              + from_port        = 443
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 443
            },
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = ""
              + from_port        = 80
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 80
            },
        ]
      + name                   = "webserver-security-group"
      + owner_id               = (known after apply)
      + revoke_rules_on_delete = false
      + vpc_id                 = (known after apply)
    }

  # module.webserver.aws_vpc.main will be created
  + resource "aws_vpc" "main" {
      + arn                              = (known after apply)
      + assign_generated_ipv6_cidr_block = false
      + cidr_block                       = "10.0.0.0/16"
      + default_network_acl_id           = (known after apply)
      + default_route_table_id           = (known after apply)
      + default_security_group_id        = (known after apply)
      + dhcp_options_id                  = (known after apply)
      + enable_classiclink               = (known after apply)
      + enable_classiclink_dns_support   = (known after apply)
      + enable_dns_hostnames             = (known after apply)
      + enable_dns_support               = true
      + id                               = (known after apply)
      + instance_tenancy                 = "default"
      + ipv6_association_id              = (known after apply)
      + ipv6_cidr_block                  = (known after apply)
      + main_route_table_id              = (known after apply)
      + owner_id                         = (known after apply)
    }

Plan: 3 to add, 0 to change, 0 to destroy.
```

`terraform apply`に対して`yes`のInputを入力すると、リソース作成後、アウトプットが表示される
```sh
Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

Outputs:

ec2_private_ip = 172.31.33.3
```


終わったら`terraform destroy`で削除しましょう。


# 7.3 Remote Moduleを使ってみよう

```sh
# remote module(terraform registry)の場合

# Ref: https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest
module "vpc_remote_module" {
  source = "terraform-aws-modules/vpc/aws" # remote moduleの場合

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}
```

`terraform apply`に対して`yes`のInputを入力すると、リソース作成後、アウトプットが表示される
```sh
Plan: 29 to add, 0 to change, 0 to destroy.
```