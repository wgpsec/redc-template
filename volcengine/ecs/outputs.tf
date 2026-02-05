output "ecs_ip" {
  value       = volcengine_eip_address.eip.eip_address
  description = "ECS public IP address"
}

output "ecs_password" {
  value       = nonsensitive(local.instance_password)
  description = "ECS SSH password"
}
