variable "region" {
  description = "UCloud 区域"
  type        = string
  default     = "cn-bj2"
}

variable "ucloud_public_key" {
  description = "UCloud Public Key"
  type        = string
  default     = ""
}

variable "ucloud_private_key" {
  description = "UCloud Private Key"
  type        = string
  default     = ""
}

variable "ucloud_project_id" {
  description = "UCloud 项目 ID（必填，请从 UCloud 控制台获取）"
  type        = string
  default     = ""
}

variable "availability_zone" {
  description = "UCloud 可用区"
  type        = string
  default     = "cn-bj2-05"
}

variable "instance_name" {
  description = "实例名称"
  type        = string
  default     = "redc-uhost"
}

variable "instance_type" {
  description = "实例规格"
  type        = string
  default     = "o-basic-1"
}

variable "instance_password" {
  description = "实例密码（8-30位，必须包含大小写字母、数字和特殊字符）"
  type        = string
  sensitive   = true
  default     = ""
}
