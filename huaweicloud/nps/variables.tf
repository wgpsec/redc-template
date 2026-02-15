variable "huaweicloud_access_key" {
  type        = string
  description = "Set HuaweiCloud access key."
  sensitive   = true
  nullable    = false
}

variable "huaweicloud_secret_key" {
  type        = string
  description = "Set HuaweiCloud secret key."
  sensitive   = true
  nullable    = false
}

variable "base64_command" {
  type        = string
  description = "base64 command"
}

variable "instance_password" {
  type        = string
  description = "Instance login password (leave empty to auto-generate)"
  sensitive   = true
  default     = ""
}
