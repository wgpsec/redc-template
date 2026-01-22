output "ecs_ip" {
  value       = "${aws_instance.dnslog.public_ip}"
  description = "ip"
}
output "web_link" {
  value       = "https://app.interactsh.com/"
  description = "web link"
}
output "web_domain" {
  value       = "a.${var.domain}"
  description = "web domain"
}