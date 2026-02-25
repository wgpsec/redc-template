output "instance_id" {
  description = "ECS 实例 ID"
  value       = ctyun_ecs.test.id
}

output "instance_name" {
  description = "ECS 实例名称"
  value       = ctyun_ecs.test.name
}

output "ecs_ip" {
  description = "公网 IP"
  value       = ctyun_ecs.test.eip_address
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
