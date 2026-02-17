output "instance_id" {
  description = "实例 ID"
  value       = volcengine_ecs_instance.this.id
}

output "instance_name" {
  description = "实例名称"
  value       = volcengine_ecs_instance.this.instance_name
}

output "public_ip" {
  description = "公网 IP"
  value       = volcengine_eip_address.this.eip_address
}

output "private_ip" {
  description = "私网 IP"
  value       = volcengine_ecs_instance.this.primary_ip_address
}

output "region" {
  description = "区域"
  value       = var.region
}

output "instance_type" {
  description = "实例规格"
  value       = var.instance_type
}

output "ssh_command" {
  description = "SSH 连接命令"
  value       = "ssh root@${volcengine_eip_address.this.eip_address}"
}

output "instance_password" {
  description = "实例登录密码"
  value       = var.instance_password
  sensitive   = true
}
