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
