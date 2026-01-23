provider "random" {}

resource "random_password" "password" {
  length = 25
  special = true
  override_special = "_+-."
  min_upper   = 1
  min_lower   = 1
  min_numeric = 1
  min_special = 1
}

resource "alicloud_instance" "instance" {
  security_groups            = alicloud_security_group.group.*.id
  instance_type              = "ecs.c7a.large"
  image_id                   = "debian_11_7_x64_20G_alibase_20230907.vhd"
  instance_name              = "yakit-server"
  vswitch_id                 = alicloud_vswitch.vswitch.id
  system_disk_category       = "cloud_essd"
  system_disk_name           = "yakit_system_disk_name"
  system_disk_description    = "yakit_system_disk_description"
  system_disk_size           = 20
  internet_max_bandwidth_out = 100
  password = random_password.password.result
  user_data                  = <<USERDATA
#!/bin/bash
sudo apt-get update
sudo apt-get install -y ca-certificates
sudo apt-get install -y wget
sudo apt-get install -y curl

sudo wget http://update.aegis.aliyun.com/download/uninstall.sh
sudo chmod +x uninstall.sh
sudo ./uninstall.sh
sudo wget http://update.aegis.aliyun.com/download/quartz_uninstall.sh
sudo chmod +x quartz_uninstall.sh
sudo ./quartz_uninstall.sh
sudo rm -fr /etc/init.d/agentwatch /usr/sbin/aliyun-service
sudo rm -rf /usr/local/aegis*
sudo rm /usr/sbin/aliyun-service
sudo rm /lib/systemd/system/aliyun.service
sudo systemctl stop aliyun.service

sudo apt-get install -y apt-transport-https
sudo apt-get install -y git
sudo apt-get install -y software-properties-common
sudo apt-get install -y gnupg
sudo apt-get install -y lrzsz
sudo apt-get install -y tmux
sudo apt-get install -y screen

sudo echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
sudo echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
sudo sysctl -p

mkdir -p /tmp/yakit && cd /tmp/yakit
rm -f yak_linux_amd64
wget https://yaklang.oss-cn-beijing.aliyuncs.com/yak/latest/yak_linux_amd64
mv --force yak_linux_amd64 /usr/local/bin/yak
chmod +x /usr/local/bin/yak
rm -rf /tmp/yakit && cd /tmp

cat > /etc/systemd/system/yakit.service << 'SERVICEFILE'
[Unit]
Description=Yakit Server
After=network.target
StartLimitIntervalSec=0

[Service]
Type=simple
Restart=on-failure
RestartSec=3
User=root
ExecStart=/usr/local/bin/yak grpc --port ${var.yakit_port}

[Install]
WantedBy=multi-user.target
SERVICEFILE

sudo chown root:root /etc/systemd/system/yakit.service
sudo chmod 644 /etc/systemd/system/yakit.service
sudo systemctl daemon-reload
sudo systemctl enable yakit
sudo systemctl start yakit

USERDATA
  depends_on = [
    alicloud_security_group.group
  ]

}

resource "alicloud_security_group" "group" {
  security_group_name        = "yakit_security_group"
  vpc_id      = alicloud_vpc.vpc.id
}

resource "alicloud_security_group_rule" "allow_ssh" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "22/22"
  priority          = 1
  security_group_id = alicloud_security_group.group.id
  cidr_ip           = "0.0.0.0/0"
  depends_on = [
    alicloud_security_group.group
  ]
}

resource "alicloud_security_group_rule" "allow_yakit_port" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "${var.yakit_port}/${var.yakit_port}"
  priority          = 1
  security_group_id = alicloud_security_group.group.id
  cidr_ip           = "0.0.0.0/0"
  depends_on = [
    alicloud_security_group.group
  ]
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
  vswitch_name = "yakit_vswitch"
}

resource "alicloud_vpc" "vpc" {
  vpc_name   = "yakit_vpc"
  cidr_block = "172.16.0.0/16"
}

data "alicloud_zones" "default" {
  available_resource_creation = "VSwitch"
  available_instance_type = "ecs.c7a.large"
}
