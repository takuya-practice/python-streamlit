data "template_file" "ssm_install_nginx_script" {
  template = file("${path.module}/install_nginx.yaml")

  vars = {
    package_name = "redis" # yamlファイル内の${package_name}に値をInject可能
  }
}

output "ssm_install_nginx_script" {
  value = data.template_file.ssm_install_nginx_script.rendered # <----- syntaxは data.template_file.<LOCAL_FILE>.rendered
}