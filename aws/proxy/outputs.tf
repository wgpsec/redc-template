output "ecs_ip" {
  value       = aws_instance.pte_node[*].public_ip
  description = "ip"
}
output "ecs_password" {
  value       = "11qqAa!@#ddddwAS"
  description = "vps password."
}

output "ssh_private_key_path" {
  description = "SSH 私钥路径"
  value       = local_file.pte_private_key.filename
}

output "ssh_user" {
  description = "SSH 登录用户名"
  value       = "admin"
}

output "ssh_commands" {
  description = "SSH 连接命令"
  value       = [for ip in aws_instance.pte_node[*].public_ip : "ssh -i ${local_file.pte_private_key.filename} admin@${ip}"]
}