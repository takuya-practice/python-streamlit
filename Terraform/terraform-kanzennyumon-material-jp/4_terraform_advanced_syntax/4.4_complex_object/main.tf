variable "object" {
  # オブジェクトとは、それぞれタイプの違うAttributeの集合体
  type = object({
    vpc_name = string
    num_of_subnets = number
    create_igw = bool
  })

  default = {
    vpc_name = "test"
    num_of_subnets = 3
    create_igw = true
  }

  # type = map(string)
  # default = {
  #   vpc_name = "test"
  #   num_of_subnets = "3"
  #   create_igw = "true"
  # }
}

variable "map" {
  # MapやListとの違いは、MapなどはAttributeのタイプが同じでなければいけない点。（例： type = map(string)）
  type = map(string)

  default = {
    vpc_name = "test"
    public_subnet_name = "public subnet"
    create_igw = true  # このAttributeタイプはboolでStringではないのでエラーになるはずだが、Terraformが””をつけてStringにConvertしてくれる。Ref:https://www.terraform.io/docs/configuration/types.html#conversion-of-complex-types
  }
}

output "object" {
  value = var.object
}

output "map" {
  value = var.map
}