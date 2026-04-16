output "ecs_ip" {
  value       = alicloud_instance.instance.public_ip
  description = "ip"
}
output "ecs_password" {
  value       = nonsensitive(local.instance_password)
  description = "vps password."
}
output "ssh_user" {
  description = "SSH 登录用户名"
  value       = "root"
}

output "ssh_command" {
  description = "SSH 连接命令"
  value       = "ssh root@${alicloud_instance.instance.public_ip}"
}

output "public_ip" {
  description = "Public IP address"
  value       = alicloud_instance.instance.public_ip
}

output "ssh_password" {
  description = "SSH password"
  value       = nonsensitive(local.instance_password)
}
