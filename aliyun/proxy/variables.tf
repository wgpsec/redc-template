variable "instance_name" {
  type        = string
  description = "Instance name (leave empty to use default)"
  default     = "proxy"
}

variable "node" {
  type        = number
  description = "node count"
}

variable "port" {
  type        = string
  description = "ss server port"
}

variable "password" {
  type        = string
  description = "ss server password"
}

variable "filename" {
  type        = string
  description = "clash file name"
}

variable "buckets_name" {
  type        = string
  description = "OSS/R2 bucket name"
}

variable "buckets_path" {
  type        = string
  description = "OSS/R2 path prefix"
}

variable "instance_password" {
  type        = string
  description = "Instance login password (leave empty to auto-generate)"
  sensitive   = true
  default     = ""
}
