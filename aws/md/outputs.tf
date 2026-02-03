output "public_ip" {
  value       = aws_instance.hackmd.public_ip
  description = "public_ip"
}

output "public_dns" {
  value       = aws_instance.hackmd.public_dns
  description = "public_dns"
}

output "md_address_link" {
  value       = "http://${aws_instance.hackmd.public_ip}:3000"
  description = "md address link."
}

output "ssh_private_key_path" {
  description = "SSH 私钥路径"
  value       = local_file.pte_private_key.filename
}

output "ssh_command" {
  description = "SSH 连接命令"
  value       = "ssh -i ${local_file.pte_private_key.filename} admin@${aws_instance.hackmd.public_ip}"
}