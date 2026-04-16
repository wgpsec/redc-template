variable "region" {
  type        = string
  description = "AWS region"
  default     = "ap-east-1"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t3.medium"
}

variable "ami" {
  type        = string
  description = "AMI ID (default: Debian x86_64 ap-east-1)"
  default     = "ami-01c6db7097043551d"
}

variable "volume_size" {
  type        = number
  description = "Root volume size in GB"
  default     = 20
}
