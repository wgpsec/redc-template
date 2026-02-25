variable "region" {
  description = "天翼云区域"
  type        = string
  default     = "cn-gd"
}

variable "availability_zone" {
  description = "可用区"
  type        = string
  default     = "cn-huadong1-jsnj1A-public-ctcloud"
}

variable "access_key" {
  description = "Access Key"
  type        = string
  default     = ""
}

variable "secret_key" {
  description = "Secret Key"
  type        = string
  default     = ""
}

variable "instance_name" {
  description = "实例名称"
  type        = string
  default     = "redc-ecs"
}

variable "instance_flavor_id" {
  description = "实例规格 ID"
  type        = string
  default     = ""
}

variable "instance_image_id" {
  description = "镜像 ID（留空则自动查询）"
  type        = string
  default     = ""
}

variable "instance_password" {
  description = "实例密码"
  type        = string
  sensitive   = true
  default     = ""
}
