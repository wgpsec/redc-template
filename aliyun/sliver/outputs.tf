output "ecs_ip" {
  value       = "${alicloud_instance.instance.public_ip}"
  description = "ip"
}
output "ecs_password" {
  value       = nonsensitive(random_password.password.result)
  description = "vps password."
}