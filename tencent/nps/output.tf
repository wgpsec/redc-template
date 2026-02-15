output "nps_ip" {
  value       = "${tencentcloud_instance.test.public_ip}"
  description = "frp ip"
}
output "nps_address_link" {
  value       = "http://${tencentcloud_instance.test.public_ip}:8080"
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
output "ecs_ip" {
  value       = "${tencentcloud_instance.test.public_ip}"
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