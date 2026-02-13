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