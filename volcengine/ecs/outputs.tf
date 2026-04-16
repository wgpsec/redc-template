output "ecs_ip" {
  value       = volcengine_eip_address.eip.eip_address
  description = "ECS public IP address"
}

output "ecs_password" {
  value       = nonsensitive(local.instance_password)
  description = "ECS SSH password"
}

output "ssh_user" {
  description = "SSH 登录用户名"
  value       = "root"
}

output "ssh_command" {
  description = "SSH 连接命令"
  value       = "ssh root@${volcengine_eip_address.eip.eip_address}"
}

output "public_ip" {
  description = "Public IP address"
  value       = volcengine_eip_address.eip.eip_address
}

output "ssh_password" {
  description = "SSH password"
  value       = nonsensitive(local.instance_password)
}
