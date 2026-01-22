output "ecs_ip" {
  value       = "${aws_instance.dnslog.public_ip}"
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