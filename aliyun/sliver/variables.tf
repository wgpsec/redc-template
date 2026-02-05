variable "github_proxy" {
  type        = string
  description = "GitHub Proxy"
}

variable "instance_password" {
  type        = string
  description = "Instance login password (leave empty to auto-generate)"
  sensitive   = true
  default     = ""
}
