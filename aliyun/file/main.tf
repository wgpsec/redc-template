locals {
  password_seed      = replace(uuid(), "-", "")
  generated_password = format("%s_+%s", substr(local.password_seed, 0, 12), substr(local.password_seed, 12, 10))
  instance_password  = var.instance_password != "" ? var.instance_password : local.generated_password
  instance_name     = var.instance_name != "" ? var.instance_name : "fileserver"
}

resource "alicloud_instance" "instance" {
  security_groups            = alicloud_security_group.group.*.id
  instance_type              = "ecs.n1.small"
  image_id                   = "debian_11_7_x64_20G_alibase_20230907.vhd"
  instance_name              = local.instance_name
  vswitch_id                 = alicloud_vswitch.vswitch.id
  system_disk_size           = 30
  internet_max_bandwidth_out = 100
  password = local.instance_password
  user_data                  = <<EOF
#!/bin/bash
sudo apt-get update
sudo apt-get install -y ca-certificates
sudo apt-get -y install wget

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

sudo apt-get -y install lrzsz
sudo sleep 1
sudo apt-get install -y tmux
sudo apt-get -y install wget
sudo apt-get -y install unzip
sudo apt-get install -y screen
sudo wget -O simplehttpserver_0.0.6_linux_amd64.zip '${var.github_proxy}/projectdiscovery/simplehttpserver/releases/download/v0.0.6/simplehttpserver_0.0.6_linux_amd64.zip'
sudo unzip simplehttpserver_0.0.6_linux_amd64.zip
sudo mv --force simplehttpserver /usr/local/bin/simplehttpserver
sudo chmod +x /usr/local/bin/simplehttpserver

sudo apt-get install -y python3-pip
sudo pip3 install trzsz

EOF
  depends_on = [
    alicloud_security_group.group
  ]

}

resource "alicloud_security_group" "group" {
  security_group_name        = "fileserver_security_group"
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

resource "alicloud_security_group_rule" "allow_all_udp" {
  type              = "ingress"
  ip_protocol       = "udp"
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
  vswitch_name = "fileserver_vswitch"

}

resource "alicloud_vpc" "vpc" {
  vpc_name   = "fileserver_vpc"
  cidr_block = "172.16.0.0/16"
}

data "alicloud_zones" "default" {
  available_resource_creation = "VSwitch"
  available_instance_type = "ecs.n1.small"
}
