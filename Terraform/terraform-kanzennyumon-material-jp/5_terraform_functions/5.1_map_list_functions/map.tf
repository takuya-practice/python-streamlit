variable "list_of_maps1" {
  type        = list(map(string))
  default     = []
}

variable "list_of_maps2" {
  type        = list(map(string))
  default     = [
    {
      name = "list_of_maps2"
    }
  ]
}

variable "list_of_maps3" {
  type        = list(map(string))
  default     = [
    {
      name = "list_of_maps3"
    }
  ]
}

output "list_of_maps" {
  value = concat(var.list_of_maps1, var.list_of_maps2, var.list_of_maps3) # ３つのリストを１つに合算する。またEmptyリストは取り除く
}

output "merged_map" {
  # { 
  #   "a" = "a"
  # },
  # {
  #   "b" = "b"
  # }
  value = merge(map("a", "a"), map("c", "c")) # ２つのmapを１つに合算する
}