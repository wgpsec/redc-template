terraform {
  required_providers {
    vultr = {
      source = "vultr/vultr"
      version = "2.22.1"
    }
  }
}

variable "VULTR_API_KEY" { }
provider "vultr" {
  api_key = var.VULTR_API_KEY
}