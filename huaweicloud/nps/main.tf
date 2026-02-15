provider "huaweicloud" {
  region     = "cn-north-4"
  access_key = var.huaweicloud_access_key
  secret_key = var.huaweicloud_secret_key
}

# 生成随机密码
locals {
  password_seed      = replace(uuid(), "-", "")
  generated_password = format("%s_+%s", substr(local.password_seed, 0, 12), substr(local.password_seed, 12, 10))
  instance_password  = var.instance_password != "" ? var.instance_password : local.generated_password
}

resource "huaweicloud_networking_secgroup" "secgroup" {
  name        = "redc_nps_secgroup"
  description = "Security group for NPS server - allow all traffic"
}

resource "huaweicloud_networking_secgroup_rule" "allow_all_ingress" {
  direction         = "ingress"
  ethertype         = "IPv4"
  security_group_id = huaweicloud_networking_secgroup.secgroup.id
  remote_ip_prefix  = "0.0.0.0/0"
}

resource "huaweicloud_networking_secgroup_rule" "allow_all_egress" {
  direction         = "egress"
  ethertype         = "IPv4"
  security_group_id = huaweicloud_networking_secgroup.secgroup.id
  remote_ip_prefix  = "0.0.0.0/0"
}

resource "huaweicloud_compute_instance" "web" {
  name               = "redc_nps_instance"
  image_id           = data.huaweicloud_images_image.myimage.id
  flavor_id          = data.huaweicloud_compute_flavors.myflavor.ids[0]
  security_group_ids = [huaweicloud_networking_secgroup.secgroup.id]
  availability_zone  = "cn-north-4a"
  admin_pass         = local.instance_password
  user_data          = <<EOF
#!/bin/bash

sudo echo "root:${local.instance_password}" | sudo chpasswd

sudo apt-get update
sudo sleep 2
sudo apt-get install -y ca-certificates
sudo apt-get -y install wget
sudo apt-get -y install unzip
sudo apt-get -y install lrzsz
sudo apt-get install -y tmux
sudo apt-get -y install wget
sudo apt-get -y install unzip

sudo wget -O linux_amd64_server.tar.gz '${var.github_proxy}/ehang-io/nps/releases/download/v0.26.10/linux_amd64_server.tar.gz'
sudo tar -zxvf linux_amd64_server.tar.gz
sudo chmod +x nps
sudo ./nps install
sudo ./nps install
sudo ./nps install
sudo ./nps install
sudo nps install

sudo echo "${var.base64_command}" | base64 -d > /etc/nps/conf/nps.conf

sudo nps start

EOF

  network {
    uuid = huaweicloud_vpc_subnet.subnet.id
  }
  depends_on = [
    huaweicloud_vpc_subnet.subnet,
    huaweicloud_networking_secgroup.secgroup
  ]
}

resource "huaweicloud_vpc" "vpc" {
  name = "redc_nps_vpc"
  cidr = "10.77.0.0/16"
}

resource "huaweicloud_vpc_subnet" "subnet" {
  name       = "redc_nps_subnet"
  cidr       = "10.77.0.0/24"
  gateway_ip = "10.77.0.1"
  vpc_id     = huaweicloud_vpc.vpc.id
  depends_on = [
    huaweicloud_vpc.vpc
  ]
}

resource "huaweicloud_vpc_eip" "eip" {
  publicip {
    type = "5_bgp"
  }
  bandwidth {
    name        = "redc_nps_eip"
    size        = 100
    share_type  = "PER"
    charge_mode = "traffic"
  }
}

resource "huaweicloud_compute_eip_associate" "associated" {
  public_ip   = huaweicloud_vpc_eip.eip.address
  instance_id = huaweicloud_compute_instance.web.id
  depends_on = [
    huaweicloud_vpc_eip.eip,
    huaweicloud_compute_instance.web
  ]
}

data "huaweicloud_compute_flavors" "myflavor" {
  availability_zone = "cn-north-4a"
  performance_type  = "normal"
  cpu_core_count    = 1
  memory_size       = 1
}

data "huaweicloud_images_image" "myimage" {
  name        = "Ubuntu 18.04 server 64bit"
  most_recent = true
}