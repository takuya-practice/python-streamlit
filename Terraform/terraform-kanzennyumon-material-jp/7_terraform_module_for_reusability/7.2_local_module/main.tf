module "webserver" {
  # 必ず必要なArg。PathはローカルファイルPathでもネット上のリンクでもOK
  source = "./modules/ec2" # <------ local moduleの場合

  # modules/ec2/main.tf はinstance_typeという変数のInputが必要
  module_instance_type = var.root_level_instance_type
}