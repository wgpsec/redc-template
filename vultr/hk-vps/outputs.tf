output "vps_ip" {
  value       = "${vultr_instance.test.main_ip}"
  description = "vps ip."
}
output "vps_os" {
  value       = "${vultr_instance.test.os}"
  description = "vps os."
}
output "vps_ram" {
  value       = "${vultr_instance.test.ram}"
  description = "vps ram."
}
output "vps_disk" {
  value       = "${vultr_instance.test.disk}"
  description = "vps disk."
}
output "vps_allowed_bandwidth" {
  value       = "${vultr_instance.test.allowed_bandwidth}"
  description = "vps allowed_bandwidth."
}
output "vps_hostname" {
  value       = "${vultr_instance.test.hostname}"
  description = "vps hostname."
}
# 为 redc SSH 功能添加标准输出
output "main_ip" {
  value       = "${vultr_instance.test.main_ip}"
  description = "Main IP address for SSH connection"
}
output "password" {
  value       = nonsensitive(vultr_instance.test.default_password)
  description = "Root password for SSH connection"
}
output "ssh_user" {
  value       = "root"
  description = "SSH login username"
}