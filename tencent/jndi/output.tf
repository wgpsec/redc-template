output "ecs_ip" {
  value       = "${tencentcloud_instance.test.public_ip}"
  description = "ip"
}
output "ecs_password" {
  value       = nonsensitive(random_password.password.result)
  description = "vps password."
}