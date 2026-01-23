terraform {
  required_providers {
    volcengine = {
      source = "volcengine/volcengine"
      version = "0.0.184"
    }
  }
}

provider "volcengine" {
  region = "cn-beijing"
  # Configuration options
}