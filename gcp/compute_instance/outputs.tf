output "instance_ip" {
  value       = google_compute_instance.default.network_interface[0].access_config[0].nat_ip
  description = "Instance public IP"
}

output "public_ip" {
  value       = google_compute_instance.default.network_interface[0].access_config[0].nat_ip
  description = "public_ip"
}

output "ssh_user" {
  description = "SSH 登录用户名 (GCP OS Login)"
  value       = "ubuntu"
}

output "ssh_command" {
  description = "SSH 连接命令"
  value       = "ssh ubuntu@${google_compute_instance.default.network_interface[0].access_config[0].nat_ip}"
}