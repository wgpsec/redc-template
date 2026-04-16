output "public_ip" {
  value       = azurerm_public_ip.redc.ip_address
  description = "public_ip"
}

output "ecs_password" {
  value       = nonsensitive(local.instance_password)
  description = "Instance login password"
}

output "ssh_user" {
  description = "SSH 登录用户名"
  value       = "redcadmin"
}

output "ssh_command" {
  description = "SSH 连接命令"
  value       = "ssh redcadmin@${azurerm_public_ip.redc.ip_address}"
}

output "ssh_password" {
  description = "SSH password"
  value       = nonsensitive(local.instance_password)
}
