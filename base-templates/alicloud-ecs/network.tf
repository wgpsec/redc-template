# VPC
resource "alicloud_vpc" "this" {
  vpc_name   = "${var.instance_name}-vpc"
  cidr_block = "172.16.0.0/16"
}

# 交换机（子网）
resource "alicloud_vswitch" "this" {
  vswitch_name = "${var.instance_name}-vswitch"
  vpc_id       = alicloud_vpc.this.id
  cidr_block   = "172.16.0.0/24"
  zone_id      = data.alicloud_zones.default.zones[local.zone_index].id
}

# 安全组
resource "alicloud_security_group" "this" {
  security_group_name = "${var.instance_name}-sg"
  vpc_id              = alicloud_vpc.this.id
}

# 安全组规则 - 允许所有入站流量
resource "alicloud_security_group_rule" "ingress" {
  type              = "ingress"
  ip_protocol       = "all"
  port_range        = "-1/-1"
  security_group_id = alicloud_security_group.this.id
  cidr_ip           = "0.0.0.0/0"
}

# 安全组规则 - 允许所有出站流量
resource "alicloud_security_group_rule" "egress" {
  type              = "egress"
  ip_protocol       = "all"
  port_range        = "-1/-1"
  security_group_id = alicloud_security_group.this.id
  cidr_ip           = "0.0.0.0/0"
}
