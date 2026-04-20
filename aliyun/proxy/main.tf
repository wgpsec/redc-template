locals {
  password_seed      = replace(uuid(), "-", "")
  generated_password = format("%s_+%s", substr(local.password_seed, 0, 12), substr(local.password_seed, 12, 10))
  instance_password  = var.instance_password != "" ? var.instance_password : local.generated_password
  instance_name      = var.instance_name != "" ? var.instance_name : "proxy"

  # 每个区域硬编码: 机型 + 可用区（已验证 spot 可用）
  region_config = {
    "cn-beijing" = {
      instance_type = "ecs.n1.tiny"
      zone_id       = "cn-beijing-f"
    }
    "ap-northeast-1" = {
      instance_type = "ecs.t5-lc1m1.small"
      zone_id       = "ap-northeast-1b"
    }
  }

  config              = local.region_config[var.region]
  final_instance_type = local.config.instance_type
  final_zone_id       = local.config.zone_id
}

resource "alicloud_instance" "instance" {
  count                      = var.node
  security_groups            = alicloud_security_group.group.*.id
  instance_type              = local.final_instance_type
  image_id                   = data.alicloud_images.debian.images[0].id
  instance_name              = local.instance_name
  vswitch_id                 = alicloud_vswitch.vswitch.id
  system_disk_size           = 20
  internet_max_bandwidth_out = 100
  password                   = local.instance_password
  spot_strategy              = "SpotWithPriceLimit"
  user_data                  = <<EOF
#!/bin/bash
sudo apt-get update
sudo sleep 2
sudo apt-get install -y ca-certificates
sudo apt-get install -y shadowsocks-libev
sudo apt-get install -y wget
sudo apt-get install -y lrzsz
sudo apt-get install -y tmux
sudo sleep 1
sudo apt-get install -y ca-certificates
sudo apt-get install -y shadowsocks-libev
sudo apt-get install -y shadowsocks-libev
sudo apt-get install -y shadowsocks-libev
sudo apt-get install -y shadowsocks-libev
sudo whoami
sudo apt-get install -y shadowsocks-libev
sudo ls
sudo apt-get install -y shadowsocks-libev
sudo sleep 2
sudo apt-get install -y shadowsocks-libev
sudo echo '{' > /etc/shadowsocks-libev/config.json
sudo echo '    "server":["0.0.0.0"],' >> /etc/shadowsocks-libev/config.json
sudo echo "    \"server_port\":${var.port}," >> /etc/shadowsocks-libev/config.json
sudo echo '    "method":"chacha20-ietf-poly1305",' >> /etc/shadowsocks-libev/config.json
sudo echo "    \"password\":\"${var.password}\"," >> /etc/shadowsocks-libev/config.json
sudo echo '    "mode":"tcp_and_udp",' >> /etc/shadowsocks-libev/config.json
sudo echo '    "fast_open":false' >> /etc/shadowsocks-libev/config.json
sudo echo '}' >> /etc/shadowsocks-libev/config.json

sudo echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
sudo echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
sudo sysctl -p

sudo echo "nameserver 223.5.5.5" > /etc/resolv.conf

sudo service shadowsocks-libev restart

sudo wget "http://update2.aegis.aliyun.com/download/uninstall.sh"
sudo chmod +x uninstall.sh
sudo ./uninstall.sh

EOF
  depends_on = [
    alicloud_security_group.group
  ]

}

resource "alicloud_security_group" "group" {
  security_group_name = "ss_security_group"
  vpc_id              = alicloud_vpc.vpc.id
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
  zone_id      = local.final_zone_id
  vswitch_name = "ss_vswitch"

}

resource "alicloud_vpc" "vpc" {
  vpc_name   = "ss_vpc"
  cidr_block = "172.16.0.0/16"
}

data "alicloud_images" "debian" {
  owners      = "system"
  name_regex  = "^debian_1[1-2].*x64"
  most_recent = true
}
