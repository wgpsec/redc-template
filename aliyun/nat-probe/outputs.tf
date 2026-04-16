output "ecs_private_ip" {
  description = "ECS 内网 IP"
  value       = alicloud_instance.ecs.private_ip
}

output "ecs_password" {
  description = "ECS 登录密码"
  value       = nonsensitive(local.instance_password)
}

output "ssh_user" {
  description = "SSH 登录用户名"
  value       = "root"
}

output "nat_gateway_id" {
  description = "NAT 网关 ID"
  value       = alicloud_nat_gateway.nat.id
}

output "eip_addresses" {
  description = "所有 EIP 地址列表"
  value       = alicloud_eip_address.eips[*].ip_address
}

output "ssh_commands" {
  description = "每个 EIP 的 SSH 连接命令"
  value       = [for i in range(var.eip_count) : "ssh -p 22 root@${alicloud_eip_address.eips[i].ip_address}  # → 内部端口 ${local.dnat_internal_ports[i]}"]
}

output "ssh_command" {
  description = "SSH 连接命令 (默认 EIP)"
  value       = "ssh root@${alicloud_eip_address.eips[0].ip_address}"
}

output "public_ip" {
  description = "默认公网 IP (第一个 EIP)"
  value       = alicloud_eip_address.eips[0].ip_address
}

output "summary" {
  description = "部署摘要"
  value       = <<-EOT
    ╔══════════════════════════════════════════════╗
    ║          NAT 多 EIP 流量探针 部署完成          ║
    ╠══════════════════════════════════════════════╣
    ║  ECS 内网 IP: ${alicloud_instance.ecs.private_ip}
    ║  EIP 数量:    ${var.eip_count}
    ║  EIP 列表:
    %{for i, eip in alicloud_eip_address.eips~}
    ║    [${i + 1}] ${eip.ip_address}
    %{endfor~}
    ║
    ║  SNAT 出口:   所有 EIP 轮换
    ║  DNAT 映射:
    %{for i in range(var.eip_count)~}
    ║    EIP[${i + 1}]:22 → ECS:${local.dnat_internal_ports[i]}
    %{endfor~}
    ║  SSH:         ssh root@${alicloud_eip_address.eips[0].ip_address}
    ╚══════════════════════════════════════════════╝
  EOT
}

output "ssh_password" {
  description = "SSH password"
  value       = nonsensitive(local.instance_password)
}
