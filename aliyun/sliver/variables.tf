variable "instance_name" {
  type        = string
  description = "Instance name (leave empty to use default)"
  default     = "sliver"
}

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
