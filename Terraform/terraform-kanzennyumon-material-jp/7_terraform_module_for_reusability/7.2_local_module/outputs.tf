# output blockを使って、"instance_ip_addr"というアウトプット変数を定義
output "ec2_private_ip" {
  value = module.webserver.ec2_private_ip
  description = "The private IP address of the main server instance."
  # sensitive = true # 任意, これを設定すると、Terraform planやapplyコマンドのアウトプットに値が表示されなくなる
}
