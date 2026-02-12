terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.25.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.2.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.8.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.6.2"
    }
  }
}