output "ecs_ip" {
  value       = aws_instance.pte_node[*].public_ip
  description = "ip"
}

output "ssh_private_key_path" {
  description = "SSH 私钥路径"
  value       = local_file.pte_private_key.filename
}