output "public_ip" {
  value       = "${aws_instance.docker.public_ip}"
  description = "public_ip"
}

output "public_dns" {
  value       = "${aws_instance.docker.public_dns}"
  description = "public_dns"
}
