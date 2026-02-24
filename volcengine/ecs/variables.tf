variable "instance_name" {
  type        = string
  description = "Instance name (leave empty to use default)"
  default     = "volcengine_ecs"
}

variable "instance_password" {
  type        = string
  description = "Instance login password (leave empty to auto-generate)"
  sensitive   = true
  default     = ""
}