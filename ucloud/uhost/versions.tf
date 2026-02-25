terraform {
  required_providers {
    ucloud = {
      source  = "ucloud/ucloud"
      version = "1.39.2"
    }
  }
}

provider "ucloud" {
  region = var.region
}
