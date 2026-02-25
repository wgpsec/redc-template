output "instance_id" {
  description = "UHost 实例 ID"
  value       = ucloud_instance.uhost.id
}

output "instance_name" {
  description = "UHost 实例名称"
  value       = ucloud_instance.uhost.name
}

output "private_ip" {
  description = "内网 IP"
  value       = ucloud_instance.uhost.private_ip
}

output "public_ip" {
  description = "公网 IP"
  value = ucloud_eip.web-eip.public_ip
}

output "ssh_user" {
  description = "SSH 用户名"
  value       = "root"
}

output "ssh_password" {
  description = "SSH 密码"
  value       = var.instance_password
  sensitive   = true
}
