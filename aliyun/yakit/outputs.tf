output "ecs_ip" {
  value       = "${alicloud_instance.instance.public_ip}"
  description = "Yakit server public IP"
}

output "ecs_password" {
  value       = nonsensitive(local.instance_password)
  description = "VPS root password"
}

output "yakit_port" {
  value       = var.yakit_port
  description = "Yakit server port"
}

output "ssh_user" {
  description = "SSH 登录用户名"
  value       = "root"
}

output "ssh_command" {
  description = "SSH 连接命令"
  value       = "ssh root@${alicloud_instance.instance.public_ip}"
}
