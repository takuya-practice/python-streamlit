# 4. Terraform Syntax上級編

# 4.1 Conditional Expression
- https://www.terraform.io/docs/configuration/expressions/conditionals.html


[4.1_conditional_expression/main.tf](4.1_conditional_expression/main.tf)
```sh
locals {
  should_create_vpc = true # <----- boolのローカル変数

  # ternaryオペレーター: condition ? true_val : false_val　のSyntax
  # if should_create_vpc == trueであれば３、else 0をnum_of_subnetsの変数にAssign
  num_of_subnets = local.should_create_vpc == true ? 3 : 0
}

output "num_of_subnets" {
  value = local.num_of_subnets # <----- num_of_subnets = 3がPrint outされる
}
```

`terraform init` `terraform apply` をすると、ローカル変数`num_of_subnets`の値が表示される
```sh
Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

num_of_subnets = 3
```



# 4.2 For loop
- https://github.com/hashicorp/terraform-guides/blob/master/infrastructure-as-code/terraform-0.12-examples/for-expressions/README.md
- https://www.terraform.io/docs/configuration/expressions/for.html


[4.2_for_loop/for_loop.tf](4.2_for_loop/for_loop.tf)
```sh
locals {
  letters = ["c","a","t"] # Stringのリスト

  # map
  cat = {
    name = "neko"
    gender = "male"
  }
}


# []内にfor loopを定義し、listをIterateする
output "upper-case-list" {
  value = [for l in local.letters: upper(l)] # Listの場合、forの前に[]でWrapする
}

# {}内にfor loopを定義し、mapをIterateする
output "upper-case-map" {
  value = {for l in local.cat: l => upper(l)} # Mapの場合、forの前に{}でWrapする
}
```

`terraform init`と `terraform apply` をすると、ローカル変数`num_of_subnets`の値が表示される
```sh
Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

upper-case-list = [ # <---- List内のItemをLoopし、Upper caseに変換されているのがわかる
  "C",
  "A",
  "T",
]
upper-case-map = { # <---- Map内のItemをLoopし、Upper caseに変換されているのがわかる
  "male" = "MALE"
  "neko" = "NEKO"
}
```


<!-- # 4.3 For-each loop: 
  - https://learn.hashicorp.com/tutorials/terraform/for-each?in=terraform/configuration-language
  - https://www.terraform.io/docs/configuration/meta-arguments/for_each.html
  - https://github.com/hashicorp/terraform-guides/tree/master/infrastructure-as-code/terraform-0.12-examples/for-each-for-resources -->




# 4.3 Dynamicブロックを使って、ListやMapのInput変数をLoopして、Resourceに値を設定する
- https://github.com/hashicorp/terraform-guides/tree/master/infrastructure-as-code/terraform-0.12-examples/dynamic-blocks-and-splat-expressions
- https://www.terraform.io/docs/configuration/expressions/dynamic-blocks.html
- https://github.com/hashicorp/terraform-guides/tree/master/infrastructure-as-code/terraform-0.12-examples/advanced-dynamic-blocks


[4.3_dynamic_block/main.tf](4.3_dynamic_block/main.tf)
```sh
variable "ingress_ports" {
  type        = list(number)
  description = "list of ingress ports"
  default     = [8200, 8201]
}

# listの変数をloopする場合
resource "aws_security_group" "vault" {
  name        = "vault"
  description = "Ingress for Vault"
  vpc_id      = aws_vpc.my_vpc.id

  # dynamic "ingress" { 
  #   for_each = var.ingress_ports
  # のSyntaxはJavaでいう下記のSyntaxに相当する
  # Iterator<Map.Entry<String, String>> ingress = var.ingress_ports.entrySet().iterator();
  
  dynamic "ingress" { # <---- localの名前を"ingress"と定義
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
```


`terraform init`と `terraform apply` をすると、２つの`setting`と`ingress`のConfigが定義されてるのがわかる
```sh
Terraform will perform the following actions:

   # aws_elastic_beanstalk_environment.tfenvtest will be created
  + resource "aws_elastic_beanstalk_environment" "tfenvtest" {
      + all_settings           = (known after apply)
      + application            = "test"
      + arn                    = (known after apply)
      + autoscaling_groups     = (known after apply)
      + cname                  = (known after apply)
      + cname_prefix           = (known after apply)
      + endpoint_url           = (known after apply)
      + id                     = (known after apply)
      + instances              = (known after apply)
      + launch_configurations  = (known after apply)
      + load_balancers         = (known after apply)
      + name                   = "tf-test-name"
      + platform_arn           = (known after apply)
      + queues                 = (known after apply)
      + solution_stack_name    = "64bit Amazon Linux 2018.03 v2.11.4 running Go 1.12.6"
      + tier                   = "WebServer"
      + triggers               = (known after apply)
      + version_label          = (known after apply)
      + wait_for_ready_timeout = "20m"

      + setting {
          + name      = "Subnets" # <---- settingsリストの１つ目のItem内の"name"keyのValue
          + namespace = "aws:ec2:vpc"
          + value     = "subnet-xxxxxxxxxxxxxxxxx"
        }
      + setting {
          + name      = "VPCId" # <---- settingsリストの２つ目のItem内の"name"keyのValueportの１つ目
          + namespace = "aws:ec2:vpc"
          + value     = "vpc-xxxxxxxxxxxxxxxxx"
        }
    }

  # aws_security_group.vault will be created
  + resource "aws_security_group" "vault" {
      + arn                    = (known after apply)
      + description            = "Ingress for Vault"
      + egress                 = (known after apply)
      + id                     = (known after apply)
      + ingress                = [
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = ""
              + from_port        = 8200 # <---- ingress portの１つ目
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 8200
            },
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = ""
              + from_port        = 8201 # <---- ingress portの２つ目 
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 8201
            },
        ]
```



# 4.4 Complex オブジェクト
- https://www.hashicorp.com/blog/terraform-0-12-rich-value-types
- https://github.com/hashicorp/terraform-guides/tree/master/infrastructure-as-code/terraform-0.12-examples/rich-value-types
- https://www.terraform.io/docs/configuration/types.html#structural-types


[4.4_complex_object/main.tf](4.4_complex_object/main.tf)
```sh
variable "network_config" {
  # オブジェクトとは、それぞれタイプの違うAttributeの集合体。MapやListとの違いは、MapなどはAttributeのタイプが同じでなければいけない点。（例： type = map(string)）
  type = object({
    vpc_name = string # <----　違うタイプが混在
    num_of_subnets = number # <----　違うタイプが混在違うタイプが混在
    create_igw = bool # <----　違うタイプが混在
  })

  default = {
    vpc_name = "test"
    num_of_subnets = 3
    create_igw = true
  }
}
```


## MapやListとの違い
- MapやListのAttributeは、全て同一のタイプでなければいけない（例： type = map(string)）
- 一方、Complex Objectは違うAttributeの集合体


`terraform init`と `terraform apply` をすると、２つの`map`と`object`のアウトプットの違い（Objectのvaluesは””で囲まれていないAttributeがある、つまりStringタイプでない）がわかる
```sh
Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

map = { # <---- 全てのValuesはstringタイプ
  "create_igw" = "true"
  "public_subnet_name" = "public subnet"
  "vpc_name" = "test"
}
object = {　# <----　Valuesのタイプは様々
  "create_igw" = true # <---- bool
  "num_of_subnets" = 3 # <---- number
  "vpc_name" = "test" # <---- string
}
```



# 4.5 Map of Map, List of Map

[4.5_nested_map/main.tf](4.5_nested_map/main.tf)
```sh
locals {
  list_of_maps = [
    {
      a = "list0a"
      b = "list0b"
    },
    {
      a = "list1a"
      b = "list1b"
    },
  ]

  map_of_maps = {
    "map_one" = {
      "item1" = "value1"
      "item2" = "value2"
    }

    "map_two" = {
      "item1" = "value3"
      "item2" = "value4"
    }
  }
  
  list_of_nested_maps = [
    {
      a = {
        a1 = "a1"
        a2 = "a2"
      }

      b = {
        b1 = "b1"
        b2 = "b2"
      }
    },
    {
      a = "list1a"
      b = "list1b"
    },
  ]
}

output "list_of_maps" {
  value = local.list_of_maps
}

output "list_of_maps_1st_map_a_value" {
  value = lookup(local.list_of_maps[0], "a")
}

output "nested_maps" {
  value = local.nested_maps
}

output "nested_maps_1st_map" {
  value = element(keys(local.nested_maps), 0)
}

output "list_of_nested_maps" {
    value = local.list_of_nested_maps
}

output "list_of_nested_maps_1st_map_a" {
    value = lookup(local.list_of_nested_maps[0], "a")
}
```

`terraform init`と `terraform apply` をすると、２つの`map`と`object`のアウトプットの違い（Objectのvaluesは””で囲まれていないAttributeがある、つまりStringタイプでない）がわかる
```sh
Outputs:

list_of_maps = [
  {
    "a" = "list0a"
    "b" = "list0b"
  },
  {
    "a" = "list1a"
    "b" = "list1b"
  },
]
list_of_maps_1st_map_a_value = list0a
list_of_nested_maps = [
  {
    "a" = {
      "a1" = "a1"
      "a2" = "a2"
    }
    "b" = {
      "b1" = "b1"
      "b2" = "b2"
    }
  },
  {
    "a" = "list1a"
    "b" = "list1b"
  },
]
list_of_nested_maps_1st_map_a = {
  "a1" = "a1"
  "a2" = "a2"
}
nested_maps = {
  "map_one" = {
    "item1" = "value1"
    "item2" = "value2"
  }
  "map_two" = {
    "item1" = "value3"
    "item2" = "value4"
  }
}
nested_maps_1st_map = map_one
```



# 4.6 File をインプットとして読み込む

[4.6_file_input/install_nginx.yaml](4.6_file_input/install_nginx.yaml)で、SSMのRun Commandドキュメントを定義
```yaml
---
schemaVersion: '2.2'
description: Install Nginx
parameters: {}
mainSteps:
- action: aws:runShellScript
  name: installNginx
  inputs:
    runCommand:
    - sudo yum update -y
    - sudo yum install nginx
    - sudo yum install ${package_name} # <--- YAMLに変数を定義することも可能
```

Dataブロックを使って、ファイルを読み込む。
[4.6_file_input/main.tf](4.6_file_input/main.tf)
```sh
data "template_file" "ssm_install_nginx_script" {
  template = file("${path.module}/install_nginx.yaml") # <----- インプットファイルのPathを指定

  vars = {
    package_name = "redis" # yamlファイル内の${package_name}に値をInject可能
  }
}

output "ssm_install_nginx_script" {
  value = data.template_file.ssm_install_nginx_script.rendered # <----- syntaxは data.template_file.<LOCAL_FILE>.rendered
}
```


`terraform init` と`terraform apply` をすると、YAMLファイルとその中の変数がInterpolateされているのがわかる
```sh
Outputs:

ssm_install_nginx_script = ---
schemaVersion: '2.2'
description: Install Nginx
parameters: {}
mainSteps:
- action: aws:runShellScript
  name: installNginx
  inputs:
    runCommand:
    - sudo yum update -y
    - sudo yum install nginx
    - sudo yum install redis # <--- YAML内の変数に値がInjectされている
```