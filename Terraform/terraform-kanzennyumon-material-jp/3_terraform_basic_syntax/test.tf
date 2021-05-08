locals {
  # maps = [
  #   {
  #     a = "list0a"
  #     b = "list0b"
  #   },
  #   {
  #     a = "list1a"
  #     b = "list1b"
  #   },
  # ]

  # nested_maps = [
  #   {
  #     a = {
  #       a1 = "a1"
  #       a2 = "a2"
  #     }

  #     b = {
  #       b1 = "b1"
  #       b2 = "b2"
  #     }
  #   },
  #   {
  #     a = "lst1a"
  #     b = "lst1b"
  #   },
  # ]

  # maps_with_template = [
  #   {
  #     item1 = "val1"
  #     item2 = "${data.template_file.test.rendered}"
  #   },
  #   {
  #     item3 = "val4"
  #     item4 = "${data.template_file.test.rendered}"
  #   },
  # ]
}

# https://stackoverflow.com/questions/43893295/map-list-of-maps-to-a-list-of-selected-field-values-in-terraform
# data "template_file" "nested_maps" {
#   count = "${length(local.nested_maps)}"
#   template = "${lookup(local.nested_maps[count.index], "a")}"
# }

# https://community.gruntwork.io/t/variables-with-compound-structure-any-workaround/100/2
# output "maps" {
#   value = lookup(local.maps[0], "a")
# }

# output "nested_maps_1" {
#     value = "${lookup(local.nested_maps[0], "a")}"
# }

# output "nested_maps_2" {
#     value = "${data.template_file.nested_maps.*.rendered[0]}"
# }



data "external" "flat_map" {
  program = ["jq", ".dictionary_name", "${path.module}/flat_map.tpl"]
  query   = {}
}

# jq can't process JSON of nested map
# data "external" "nested_map" {
#   program = ["jq", ".dictionary_name", "${path.module}/nested_map.tpl"]
#   query = { }
# }

output "flat_map_4" {
  value = "${data.external.flat_map.result["key1"]}"
}

# output "nested_map_5" {
#   value = "${data.external.nested_map.result["key1"]}"
# }

# data "template_file" "test" {
#   template = "${file("test.json.tpl")}"
# }

# output "maps_with_template" {
#   value = "${lookup(local.maps_with_template[0], "item2")}"
# }

# variable "policies_arns" {
#   # default = "${local.config_aggregator_iam_role_policies_arns}"
# }

# locals {
#   config_aggregator_iam_role_policies_arns = ["${data.aws_iam_policy.config_aggregator_iam_role_for_orgs.arn}"]
# }

variable "policies_count" {
  default = 1
}

# data "aws_iam_policy" "config_aggregator_iam_role_for_orgs" {
#   arn = "arn:aws:iam::aws:policy/service-role/AWSConfigRoleForOrganizations"
# }

# output "test_list_size" {
#   value = "${length(local.config_aggregator_iam_role_policies_arns) + var.policies_count}"
# }

variable "UPPERCASE" {
  default = "UPPERCASE"
}
output "lowercased" {
  value = "${lower(var.UPPERCASE)}"
}

variable "map" {
  type    = "map"
  default = {
    "a" = "a"
    "b" = "b"
  }
}

# output "merged_map" {
#   value = "${merge(var.map, map("c", "c"))}"
# }

# data "aws_region" "current" {}

# locals {
#   alarm_actions = ["arn:aws:automate:${data.aws_region.current.name}:ec2:recover"]
# }
# output "aws_region" {
#   value = "${local.alarm_actions}"
# }