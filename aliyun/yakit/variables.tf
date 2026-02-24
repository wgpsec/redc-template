variable "instance_name" {
  type        = string
  description = "Instance name (leave empty to use default)"
  default     = "yakit-server"
}

variable "yakit_port" {
  type        = number
  description = "Yakit server listening port"
  default     = 8087
}

variable "instance_password" {
  type        = string
  description = "Instance login password (leave empty to auto-generate)"
  sensitive   = true
  default     = ""
}
