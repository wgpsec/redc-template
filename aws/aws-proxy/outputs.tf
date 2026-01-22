output "ecs_ip" {
  value       = "${aws_instance.pte_node[*].public_ip}"
  description = "ip"
}
output "ecs_password" {
  value       = "11qqAa!@#ddddwAS"
  description = "vps password."
}