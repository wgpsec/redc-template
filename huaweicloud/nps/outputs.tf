output "nps_ip" {
  value       = "${huaweicloud_compute_eip_associate.associated.public_ip}"
  description = "nps ip."
}

output "nps_address_link" {
  value       = "http://${huaweicloud_compute_eip_associate.associated.public_ip}:8080"
  description = "nps address link."
}

output "nps_username" {
  value       = "redone"
  description = "nps username."
}

output "nps_password" {
  value       = "1!2A3d4v5s6e"
  description = "nps password."
}

# SSH 相关输出，用于 redc SSH 功能
output "ecs_ip" {
  value       = "${huaweicloud_compute_eip_associate.associated.public_ip}"
  description = "Instance IP for SSH connection"
}

output "ecs_password" {
  value       = nonsensitive(local.instance_password)
  description = "Instance root password for SSH connection"
}

output "ssh_user" {
  value       = "root"
  description = "SSH login username"
}
