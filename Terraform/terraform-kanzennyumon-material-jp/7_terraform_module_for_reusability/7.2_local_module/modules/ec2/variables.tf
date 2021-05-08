variable "module_instance_type" {}

variable "security_group_ingress_ports" {
  type        = list(number)
  description = "list of ingress ports"
  default     = [80, 443]
}