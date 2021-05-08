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

  list_of_nested_maps = [
    {
      a = {
        a1 = "a1_value"
        a2 = "a2_value"
      }

      b = {
        b1 = "b1_value"
        b2 = "b2_value"
      }
    },
    {
      a = "list1a_value"
      b = "list1b_value"
    },
  ]

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
  value = lookup(local.nested_maps, "map_one")
}

output "nested_maps_1st_map_name" {
  value = element(keys(local.nested_maps), 0)
}

output "list_of_nested_maps" {
    value = local.list_of_nested_maps
}

output "list_of_nested_maps_1st_map_a" {
    value = lookup(local.list_of_nested_maps[0], "a")
}

output "list_of_nested_maps_1st_map_a_a2_value" {
    value = lookup(lookup(local.list_of_nested_maps[0], "a"), "a2")
}
