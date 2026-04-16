variable "region" {
  type        = string
  description = "AWS region"
  default     = "ap-east-1"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t4g.micro"
}

variable "ami" {
  type        = string
  description = "AMI ID (default: Debian arm64 ap-east-1)"
  default     = "ami-01c9cc5554738042c"
}

variable "volume_size" {
  type        = number
  description = "Root volume size in GB"
  default     = 18
}
