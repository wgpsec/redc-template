locals {
  password_seed      = replace(uuid(), "-", "")
  generated_password = format("%s_+%s", substr(local.password_seed, 0, 12), substr(local.password_seed, 12, 10))
  instance_password  = var.instance_password != "" ? var.instance_password : local.generated_password
  instance_name     = var.instance_name != "" ? var.instance_name : "volcengine_ecs_${local.random_suffix}"

  # 生成8位随机后缀用于资源命名，避免名称冲突
  random_suffix = substr(replace(uuid(), "-", ""), 0, 8)
}

resource "volcengine_ecs_instance" "instance" {
  instance_name        = local.instance_name
  instance_type        = "ecs.e-c1m1.large"
  image_id             = data.volcengine_images.debian.images[0].image_id
  subnet_id            = volcengine_subnet.subnet.id
  security_group_ids   = [volcengine_security_group.group.id]
  system_volume_type   = "ESSD_PL0"
  system_volume_size   = 20
  instance_charge_type = "PostPaid"
  password             = local.instance_password

  user_data = base64encode(<<EOF
#!/bin/bash
sudo apt-get update
sudo apt-get install -y ca-certificates
sudo apt-get install -y curl
sudo apt-get -y install wget
sudo apt-get install -y lrzsz
sudo apt-get install -y tmux
sudo apt-get install -y unzip
sudo echo "set-option -g history-limit 20000" >> ~/.tmux.conf
sudo echo "set -g mouse on" >> ~/.tmux.conf

sudo echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
sudo echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
sudo sysctl -p

sudo apt-get install -y python3-pip
sudo pip3 install trzsz --break-system-packages

EOF
  )
}

resource "volcengine_eip_address" "eip" {
  billing_type = "PostPaidByTraffic"
  bandwidth    = 100
  isp          = "BGP"
  name         = "volcengine_bj_eip_${local.random_suffix}"
  description  = "EIP for ECS instance"
}

resource "volcengine_eip_associate" "eip_attach" {
  allocation_id = volcengine_eip_address.eip.id
  instance_id   = volcengine_ecs_instance.instance.id
  instance_type = "EcsInstance"
}

resource "volcengine_security_group" "group" {
  security_group_name = "volcengine_security_group_${local.random_suffix}"
  vpc_id              = volcengine_vpc.vpc.id
}

resource "volcengine_security_group_rule" "allow_all_tcp" {
  direction         = "ingress"
  security_group_id = volcengine_security_group.group.id
  protocol          = "tcp"
  port_start        = 1
  port_end          = 65535
  cidr_ip           = "0.0.0.0/0"
  depends_on = [
    volcengine_security_group.group
  ]
}

resource "volcengine_vpc" "vpc" {
  vpc_name   = "volcengine_vpc_${local.random_suffix}"
  cidr_block = "172.16.0.0/16"
}

resource "volcengine_subnet" "subnet" {
  subnet_name = "volcengine_subnet_${local.random_suffix}"
  cidr_block  = "172.16.0.0/24"
  zone_id     = data.volcengine_zones.default.zones[0].id
  vpc_id      = volcengine_vpc.vpc.id
}

data "volcengine_zones" "default" {
}

data "volcengine_images" "debian" {
  os_type          = "Linux"
  visibility       = "public"
  instance_type_id = "ecs.e-c1m1.large"
  name_regex       = "Debian 12"
}
