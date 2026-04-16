output "ecs_ip" {
  value       = tencentcloud_instance.test.public_ip
  description = "ip"
}
output "ecs_password" {
  value       = nonsensitive(local.instance_password)
  description = "vps password."
}
output "ssh_user" {
  value       = "ubuntu"
  description = "SSH login username"
}

output "public_ip" {
  description = "Public IP address"
  value       = tencentcloud_instance.test.public_ip
}

output "ssh_password" {
  description = "SSH password"
  value       = nonsensitive(local.instance_password)
}
