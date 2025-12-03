output "ecs_ip" {
  value       = "${alicloud_instance.instance[*].public_ip}"
  description = "ip"
}