locals {
  should_create_vpc = true # <----- boolのローカル変数

  # ternaryオペレーター: condition ? true_val : false_val　のSyntax
  # if should_create_vpc == trueであれば３、else 0をnum_of_subnetsの変数にAssign
  num_of_subnets = local.should_create_vpc == true ? 3 : 0
}

output "num_of_subnets" {
  value = local.num_of_subnets
}