output "id" {
  description = "The instance ID."
  value = aws_instance.example.id
}
output "arn" {
  description = "The ARN of the instance."
  value = aws_instance.example.arn
}
output "availability_zone" {
  description = "The availability zone of the instance."
  value = aws_instance.example.availability_zone
}
output "placement_group" {
  description = "The placement group of the instance."
  value = aws_instance.example.placement_group
}
output "key_name" {
  description = "The key name of the instance"
  value = aws_instance.example.key_name
}
output "password_data" {
  description = "Base-64 encoded encrypted password data for the instance. Useful for getting the administrator password for instances running Microsoft Windows. This attribute is only exported if get_password_data is true. Note that this encrypted value will be stored in the state file, as with all exported attributes. See GetPasswordData for more information."
  value = aws_instance.example.password_data
}
output "public_dns" {
  description = "The public DNS name assigned to the instance. For EC2-VPC, this is only available if you've enabled DNS hostnames for your VPC"
  value = aws_instance.example.public_dns
}
output "public_ip" {
  description = "The public IP address assigned to the instance, if applicable. NOTE: If you are using an aws_eip with your instance, you should refer to the EIP's address directly and not use public_ip, as this field will change after the EIP is attached."
  value = aws_instance.example.public_ip
}
output "ipv6_addresses" {
  description = "A list of assigned IPv6 addresses, if any"
  value = aws_instance.example.ipv6_addresses
}
output "primary_network_interface_id" {
  description = "The ID of the instance's primary network interface."
  value = aws_instance.example.primary_network_interface_id
}
output "private_dns" {
  description = "The private DNS name assigned to the instance. Can only be used inside the Amazon EC2, and only available if you've enabled DNS hostnames for your VPC"
  value = aws_instance.example.private_dns
}
output "private_ip" {
  description = "The private IP address assigned to the instance"
  value = aws_instance.example.private_ip
}
output "security_groups" {
  description = "The associated security groups."
  value = aws_instance.example.security_groups
}
output "vpc_security_group_ids" {
  description = "The associated security groups in non-default VPC"
  value = aws_instance.example.vpc_security_group_ids
}
output "subnet_id" {
  description = "The VPC subnet ID."
  value = aws_instance.example.subnet_id
}
output "outpost_arn" {
  description = "The ARN of the Outpost the instance is assigned to."
  value = aws_instance.example.outpost_arn
}
output "credit_specification" {
  description = "Credit specification of instance."
  value = aws_instance.example.credit_specification
}