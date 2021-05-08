locals {
  # string: ダブルQuoteで定義されたText
  string_var = "Matt Damon"

  # string interporation： 
  # ${} templatesを使って、変数の値をString literalに埋め込める
  # ref: https://www.terraform.io/docs/configuration/expressions/strings.html#string-templates
  greeting = "Hello ${local.string_var}" # <--"Hello Matt Damon"が表示される

  # number: quoteなしの数字
  timeout_seconds = 60

  # bool: boolean value, quoteなしのtrueかfalse
  should_create_vpc = true # <----- quoteなし

  # list: []内に定義されたリストのItem
  aws_regions = ["us-west-1a", "us-west-1c"]

  # map: {}内に定義された <KEY> = <VALUE> ペア
  map = {
    name = "John"
    age  = 52
  }
}

variable "number_of_vpc" {
  default = 3
  type = number
  description = "asasdasdas"
}


output "string_var" {
  value = local.string_var
}

output "greeting" {
  value = local.greeting
}

output "timeout_seconds" {
  value = local.timeout_seconds
}

output "should_create_vpc" {
  value = local.should_create_vpc
}

output "aws_regions_list" {
  value = local.aws_regions
}

output "aws_regions_list_1st_item" {
  value = local.aws_regions[0] # 0番目のItemをアクセス
}

output "person_map" {
  value = local.map
}

output "person_map_name" {
  value = local.map["name"] # map内のKey"name"の値をアクセス
}