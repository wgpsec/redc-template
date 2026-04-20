terraform {
  required_providers {
    alicloud = {
      source  = "aliyun/alicloud"
      version = "1.241.0"
    }
  }
}

provider "alicloud" {
  profile = "cloud-tool"
  region  = var.region
  endpoints {
    ecs = "ecs.aliyuncs.com"
    vpc = "vpc.aliyuncs.com"
  }
}