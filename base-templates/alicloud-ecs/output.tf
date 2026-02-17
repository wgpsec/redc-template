output "instance_id" {
  description = "实例 ID"
  value       = alicloud_instance.this.id
}

output "instance_name" {
  description = "实例名称"
  value       = alicloud_instance.this.instance_name
}

output "public_ip" {
  description = "公网 IP"
  value       = alicloud_instance.this.public_ip
}

output "private_ip" {
  description = "私网 IP"
  value       = alicloud_instance.this.private_ip
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
  value       = "ssh root@${alicloud_instance.this.public_ip}"
}

output "available_zones" {
  description = "支持该实例规格的所有可用区"
  value       = data.alicloud_zones.default.zones[*].id
}

output "selected_zone" {
  description = "当前使用的可用区"
  value       = data.alicloud_zones.default.zones[local.zone_index].id
}

output "instance_password" {
  description = "实例登录密码"
  value       = var.instance_password
  sensitive   = true
}
