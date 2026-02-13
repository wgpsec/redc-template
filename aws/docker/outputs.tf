output "public_ip" {
  value       = aws_instance.docker.public_ip
  description = "public_ip"
}

output "public_dns" {
  value       = aws_instance.docker.public_dns
  description = "public_dns"
}

output "ssh_private_key_path" {
  description = "SSH 私钥路径"
  value       = local_file.pte_private_key.filename
}

output "ssh_user" {
  description = "SSH 登录用户名"
  value       = "admin"
}

output "ssh_command" {
  description = "SSH 连接命令"
  value       = "ssh -i ${local_file.pte_private_key.filename} admin@${aws_instance.docker.public_ip}"
}
