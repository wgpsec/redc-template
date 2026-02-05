locals {
  password_seed      = replace(uuid(), "-", "")
  generated_password = format("%s_+%s", substr(local.password_seed, 0, 12), substr(local.password_seed, 12, 10))
  instance_password  = var.instance_password != "" ? var.instance_password : local.generated_password
}

resource "alicloud_instance" "instance" {
  security_groups            = alicloud_security_group.group.*.id
  instance_type              = "ecs.e-c1m2.large"
  image_id                   = "debian_12_2_x64_20G_alibase_20231012.vhd"
  instance_name              = "aliyun_bj_ecs"
  vswitch_id                 = alicloud_vswitch.vswitch.id
  system_disk_category       = "cloud_essd_entry"
  system_disk_size           = 20
  internet_max_bandwidth_out = 100
  password = local.instance_password
user_data                  = <<EOF
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

sudo wget http://update.aegis.aliyun.com/download/uninstall.sh
sudo chmod +x uninstall.sh
sudo ./uninstall.sh
sudo wget http://update.aegis.aliyun.com/download/quartz_uninstall.sh
sudo chmod +x quartz_uninstall.sh
sudo ./quartz_uninstall.sh
sudo pkill aliyun-service
sudo rm -fr /etc/init.d/agentwatch /usr/sbin/aliyun-service
sudo rm -rf /usr/local/aegis*
sudo rm /usr/sbin/aliyun-service
sudo rm /lib/systemd/system/aliyun.service
sudo systemctl stop aliyun.service

sudo echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
sudo echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
sudo sysctl -p

sudo apt-get install -y python3-pip
sudo pip3 install trzsz --break-system-packages

EOF

}

resource "alicloud_security_group" "group" {
  security_group_name        = "test_security_group"
  vpc_id      = alicloud_vpc.vpc.id
}

resource "alicloud_security_group_rule" "allow_all_tcp" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "1/65535"
  priority          = 1
  security_group_id = alicloud_security_group.group.id
  cidr_ip           = "0.0.0.0/0"
  depends_on = [
    alicloud_security_group.group
  ]
}

resource "alicloud_vswitch" "vswitch" {
  vpc_id       = alicloud_vpc.vpc.id
  cidr_block   = "172.16.0.0/24"
  zone_id           = data.alicloud_zones.default.zones[0].id
  vswitch_name = "aliyun_zjk_vswitch"

}
resource "alicloud_vpc" "vpc" {
  vpc_name   = "test_vpc"
  cidr_block = "172.16.0.0/16"
}

data "alicloud_zones" "default" {
  available_resource_creation = "VSwitch"
  available_instance_type = "ecs.e-c1m2.large"
}
