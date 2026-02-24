variable "region" {
  description = "阿里云区域"
  type        = string
}

variable "cloud_provider" {
  description = "云厂商标识"
  type        = string
  default     = "alicloud"
}

variable "instance_type" {
  description = "实例规格"
  type        = string
}

variable "instance_name" {
  description = "实例名称"
  type        = string
  default     = "alicloud-ecs-instance"
}

variable "instance_password" {
  description = "实例密码（8-30个字符，必须包含大小写字母、数字）。如果不提供，系统会自动生成"
  type        = string
  sensitive   = true
  default     = ""
}

variable "system_disk_size" {
  description = "系统盘大小 (GB)"
  type        = number
  default     = 40
}

variable "system_disk_category" {
  description = "系统盘类型"
  type        = string
  default     = "cloud_efficiency"
}

variable "userdata" {
  description = "用户数据脚本"
  type        = string
  default     = ""
}

variable "internet_max_bandwidth_out" {
  description = "公网带宽 (Mbps)"
  type        = number
  default     = 1
}

variable "is_spot_instance" {
  description = "是否为抢占式实例 (true/false)"
  type        = bool
  default     = false
}
