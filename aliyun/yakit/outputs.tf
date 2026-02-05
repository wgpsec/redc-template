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
