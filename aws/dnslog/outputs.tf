output "ecs_ip" {
  value       = aws_instance.dnslog.public_ip
  description = "ip"
}
output "web_link" {
  value       = "http://red123:r1e2d3o4n5e6123@${aws_instance.dnslog.public_ip}/"
  description = "web link"
}
output "web_user" {
  value       = "red123"
  description = "web user"
}
output "web_pass" {
  value       = "r1e2d3o4n5e6123"
  description = "web pass"
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