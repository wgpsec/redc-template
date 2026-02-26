variable "GCP_PROJECT_ID" {
  type        = string
  description = "GCP_PROJECT ID"
  default = "redc-488606"
}

variable "instance_name" {
  type    = string
  default = "vm-test"
}

variable "instance_machine_type" {
  type    = string
  default = "e2-micro"
}

variable "location" {
  type    = string
  default = "us-central1"
}

variable "zone" {
  type    = string
  default = "us-central1-a"
}

variable "image" {
  type    = string
  default = "ubuntu-minimal-2210-kinetic-amd64-v20230126"
}
