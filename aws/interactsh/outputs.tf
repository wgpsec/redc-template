output "ecs_ip" {
  value       = aws_instance.dnslog.public_ip
  description = "ip"
}
output "web_link" {
  value       = "https://app.interactsh.com/"
  description = "web link"
}
output "web_domain" {
  value       = var.domain
  description = "web domain"
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
  value       = "ssh -i ${local_file.pte_private_key.filename} admin@${aws_instance.dnslog.public_ip}"
}