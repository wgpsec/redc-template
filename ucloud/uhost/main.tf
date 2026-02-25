# UCloud UHost 实例

resource "random_id" "instance_suffix" {
  byte_length = 4
}

locals {
  instance_name = var.instance_name != "" ? var.instance_name : "redc-${random_id.instance_suffix.hex}"
}

# 查询可用镜像
data "ucloud_images" "default" {
  availability_zone = var.availability_zone
  name_regex       = "Debian 12.7"
  image_type       = "base"
}

data "ucloud_security_groups" "default" {
  type = "recommend_web"
}

# 创建 VPC
resource "ucloud_vpc" "default" {
  name = "tf-example-intranet-cluster"
  tag = "tf-example"

  # vpc network
  cidr_blocks = ["192.168.0.0/16"]
}

resource "ucloud_subnet" "default" {
    name = "tf-example-intranet-cluster"
    tag = "tf-example"
    cidr_block = "192.168.1.0/24"
    vpc_id = ucloud_vpc.default.id
}

# UHost 实例
resource "ucloud_instance" "uhost" {
  name              = local.instance_name
  instance_type     = var.instance_type
  image_id          = data.ucloud_images.default.images[0].id
  root_password     = var.instance_password
  availability_zone = var.availability_zone
  tag = "redc"
  charge_type = "dynamic"
  security_group = data.ucloud_security_groups.default.security_groups[0].id

  boot_disk_type    = "cloud_ssd"
  # create cloud data disk attached to instance
  data_disks {
    size = 20
    type = "cloud_ssd"
  }
  delete_disks_with_instance = true

  user_data = <<EOF
#!/bin/bash

EOF
}

resource "ucloud_eip" "web-eip" {
  internet_type = "bgp"
  charge_mode   = "bandwidth"
  charge_type   = "dynamic"
  name          = "web-eip"
  bandwidth     = 1
}

resource "ucloud_eip_association" "web-eip-association" {
  eip_id      = ucloud_eip.web-eip.id
  resource_id = ucloud_instance.uhost.id
}
