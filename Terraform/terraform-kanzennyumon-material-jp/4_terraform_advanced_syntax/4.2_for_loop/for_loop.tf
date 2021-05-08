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
  value = [for item in local.letters: upper(item)] # Listの場合、forの前に[]でWrapする
}

# {}内にfor loopを定義し、mapをIterateする
output "upper-case-map" {
  value = {for entry in local.cat: entry => upper(entry)} # Mapの場合、forの前に{}でWrapする
}
