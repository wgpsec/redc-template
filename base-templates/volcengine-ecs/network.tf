# VPC
resource "volcengine_vpc" "this" {
  vpc_name   = "${var.instance_name}-vpc"
  cidr_block = "172.16.0.0/16"
}

# 子网
resource "volcengine_subnet" "this" {
  subnet_name = "${var.instance_name}-subnet"
  cidr_block  = "172.16.0.0/24"
  zone_id     = data.volcengine_zones.default.zones[0].id
  vpc_id      = volcengine_vpc.this.id
}

# 安全组
resource "volcengine_security_group" "this" {
  vpc_id              = volcengine_vpc.this.id
  security_group_name = "${var.instance_name}-sg"
}

# 安全组规则 - 允许 SSH
resource "volcengine_security_group_rule" "ssh" {
  direction         = "ingress"
  security_group_id = volcengine_security_group.this.id
  protocol          = "tcp"
  port_start        = 22
  port_end          = 22
  cidr_ip           = "0.0.0.0/0"
}

# 安全组规则 - 允许 HTTP
resource "volcengine_security_group_rule" "http" {
  direction         = "ingress"
  security_group_id = volcengine_security_group.this.id
  protocol          = "tcp"
  port_start        = 80
  port_end          = 80
  cidr_ip           = "0.0.0.0/0"
}

# 安全组规则 - 允许 HTTPS
resource "volcengine_security_group_rule" "https" {
  direction         = "ingress"
  security_group_id = volcengine_security_group.this.id
  protocol          = "tcp"
  port_start        = 443
  port_end          = 443
  cidr_ip           = "0.0.0.0/0"
}

# 安全组规则 - 允许所有出站流量
resource "volcengine_security_group_rule" "egress" {
  direction         = "egress"
  security_group_id = volcengine_security_group.this.id
  protocol          = "all"
  port_start        = -1
  port_end          = -1
  cidr_ip           = "0.0.0.0/0"
}

# 公网 IP
resource "volcengine_eip_address" "this" {
  billing_type = "PostPaidByBandwidth"
  bandwidth    = var.internet_max_bandwidth_out
  isp          = "BGP"
  name         = "${var.instance_name}-eip"
  description  = "EIP for ${var.instance_name}"
}

# 绑定公网 IP
resource "volcengine_eip_associate" "this" {
  allocation_id = volcengine_eip_address.this.id
  instance_id   = volcengine_ecs_instance.this.id
  instance_type = "EcsInstance"
}
