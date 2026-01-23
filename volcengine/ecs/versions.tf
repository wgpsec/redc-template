terraform {
  required_providers {
    volcengine = {
      source  = "volcengine/volcengine"
      version = "0.0.159"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "volcengine" {
  region = "cn-beijing"
  # access_key and secret_key can be provided via environment variables:
  # VOLCENGINE_ACCESS_KEY and VOLCENGINE_SECRET_KEY
}
