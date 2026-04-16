variable "region" {
  type        = string
  description = "Vultr region"
  default     = "sgp"
}

variable "plan" {
  type        = string
  description = "Vultr plan"
  default     = "vc2-1c-2gb"
}

variable "os_id" {
  type        = number
  description = "Vultr OS ID (477 = Ubuntu 22.04 x64)"
  default     = 477
}
