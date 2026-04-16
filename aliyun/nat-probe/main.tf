# ──────────────────────────────────────────────────
# 阿里云 ECS + NAT 网关 + 多 EIP 流量探针
# ──────────────────────────────────────────────────

locals {
  password_seed      = replace(uuid(), "-", "")
  generated_password = format("%s_+%s", substr(local.password_seed, 0, 12), substr(local.password_seed, 12, 10))
  instance_password  = var.instance_password != "" ? var.instance_password : local.generated_password
  # DNAT 端口映射: EIP[0]→22, EIP[1]→122, EIP[2]→222, ...
  dnat_internal_ports = [for i in range(var.eip_count) : i == 0 ? 22 : (i * 100 + 22)]
}

# ── 数据源 ─────────────────────────────────────────
data "alicloud_zones" "default" {
  available_resource_creation = "VSwitch"
  available_instance_type     = var.instance_type
}

data "alicloud_enhanced_nat_available_zones" "default" {}

locals {
  nat_zones = data.alicloud_enhanced_nat_available_zones.default.zones[*].zone_id
  ecs_zones = data.alicloud_zones.default.zones[*].id
  # 取 ECS 和 NAT 都有库存的可用区
  common_zones = [for z in local.ecs_zones : z if contains(local.nat_zones, z)]
  zone_id      = length(local.common_zones) > 0 ? local.common_zones[0] : local.ecs_zones[0]
}

# ── 网络基础设施 ────────────────────────────────────
resource "alicloud_vpc" "vpc" {
  vpc_name   = "${var.instance_name}-vpc"
  cidr_block = "172.16.0.0/16"
}

resource "alicloud_vswitch" "vswitch" {
  vpc_id       = alicloud_vpc.vpc.id
  cidr_block   = "172.16.0.0/24"
  zone_id      = local.zone_id
  vswitch_name = "${var.instance_name}-vsw"
}

resource "alicloud_security_group" "sg" {
  security_group_name = "${var.instance_name}-sg"
  vpc_id              = alicloud_vpc.vpc.id
}

resource "alicloud_security_group_rule" "allow_all_tcp" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "1/65535"
  priority          = 1
  security_group_id = alicloud_security_group.sg.id
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "allow_all_udp" {
  type              = "ingress"
  ip_protocol       = "udp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "1/65535"
  priority          = 1
  security_group_id = alicloud_security_group.sg.id
  cidr_ip           = "0.0.0.0/0"
}

# ── ECS 实例 (无公网 IP，走 NAT 出网) ──────────────
resource "alicloud_instance" "ecs" {
  security_groups            = [alicloud_security_group.sg.id]
  instance_type              = var.instance_type
  image_id                   = "debian_12_2_x64_20G_alibase_20231012.vhd"
  instance_name              = var.instance_name
  vswitch_id                 = alicloud_vswitch.vswitch.id
  system_disk_category       = "cloud_essd_entry"
  system_disk_size           = 20
  internet_max_bandwidth_out = 0
  password                   = local.instance_password

  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y ca-certificates curl wget lrzsz tmux unzip tcpdump nmap net-tools

    # tmux 配置
    echo "set-option -g history-limit 20000" >> ~/.tmux.conf
    echo "set -g mouse on" >> ~/.tmux.conf

    # BBR 加速
    echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
    echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf

    # 开启 IP 转发 (NAT 探针必需)
    echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
    sysctl -p

    # 卸载云盾
    wget -q http://update.aegis.aliyun.com/download/uninstall.sh && chmod +x uninstall.sh && ./uninstall.sh
    wget -q http://update.aegis.aliyun.com/download/quartz_uninstall.sh && chmod +x quartz_uninstall.sh && ./quartz_uninstall.sh
    pkill aliyun-service
    rm -fr /etc/init.d/agentwatch /usr/sbin/aliyun-service /usr/local/aegis* /lib/systemd/system/aliyun.service
    systemctl stop aliyun.service 2>/dev/null

    # 配置 SSH 监听多端口 (每个 EIP 对应一个内部端口)
    # 必须显式写 Port 22，否则添加其他 Port 后默认 22 会被覆盖
    echo "Port 22" >> /etc/ssh/sshd_config
    %{for i in range(var.eip_count)~}
    %{if i > 0~}
    echo "Port ${i * 100 + 22}" >> /etc/ssh/sshd_config
    %{endif~}
    %{endfor~}
    systemctl restart sshd

    # trzsz
    apt-get install -y python3-pip
    pip3 install trzsz --break-system-packages 2>/dev/null || pip3 install trzsz
  EOF
}

# ── NAT 网关 ─────────────────────────────────────
resource "alicloud_nat_gateway" "nat" {
  vpc_id           = alicloud_vpc.vpc.id
  nat_gateway_name = "${var.instance_name}-nat"
  payment_type     = "PayAsYouGo"
  vswitch_id       = alicloud_vswitch.vswitch.id
  nat_type         = "Enhanced"
}

# ── 多个 EIP ──────────────────────────────────────
resource "alicloud_eip_address" "eips" {
  count                = var.eip_count
  address_name         = "${var.instance_name}-eip-${count.index + 1}"
  bandwidth            = var.eip_bandwidth
  internet_charge_type = "PayByTraffic"
  payment_type         = "PayAsYouGo"
  isp                  = var.eip_isp
}

# ── EIP 绑定到 NAT 网关 ──────────────────────────
resource "alicloud_eip_association" "bindnat" {
  count         = var.eip_count
  allocation_id = alicloud_eip_address.eips[count.index].id
  instance_id   = alicloud_nat_gateway.nat.id
  instance_type = "Nat"
}

# ── SNAT 规则: 所有 EIP 作为出口 IP 池 (多 IP 轮换) ──
resource "alicloud_snat_entry" "default_snat" {
  snat_table_id     = alicloud_nat_gateway.nat.snat_table_ids
  source_vswitch_id = alicloud_vswitch.vswitch.id
  snat_ip           = join(",", alicloud_eip_address.eips[*].ip_address)

  depends_on = [alicloud_eip_association.bindnat]
}

# ── DNAT 规则: 每个 EIP:22 → ECS 不同端口 ──────────
# EIP[0]:22→22, EIP[1]:22→122, EIP[2]:22→222, ...
# 通过内部端口区分流量来自哪个 EIP
resource "alicloud_forward_entry" "dnat_ssh" {
  count              = var.eip_count
  forward_table_id   = alicloud_nat_gateway.nat.forward_table_ids
  external_ip        = alicloud_eip_address.eips[count.index].ip_address
  external_port      = "22"
  ip_protocol        = "tcp"
  internal_ip        = alicloud_instance.ecs.private_ip
  internal_port      = tostring(local.dnat_internal_ports[count.index])
  port_break         = true
  forward_entry_name = "${var.instance_name}-ssh-eip${count.index + 1}"

  depends_on = [alicloud_eip_association.bindnat]
}
