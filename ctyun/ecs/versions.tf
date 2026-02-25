terraform {
  required_providers {
    ctyun = {
      source = "ctyun-it/ctyun"
      version = "2.0.0"
    }
  }
}

provider "ctyun" {
  region_id = "bb9fdb42056f11eda1610242ac110002"
}
