variable "tencentcloud_secret_id" {
  type        = string
  description = "Set TencentCloud secret id."
  sensitive   = true
  nullable    = false
}

variable "tencentcloud_secret_key" {
  type        = string
  description = "Set TencentCloud secret key."
  sensitive   = true
  nullable    = false
}

variable "instance_password" {
  type        = string
  description = "Instance login password (leave empty to auto-generate)"
  sensitive   = true
  default     = ""
}
