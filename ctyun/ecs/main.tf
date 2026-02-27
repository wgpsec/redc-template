# 天翼云 ECS 实例

locals {
  random_seed      = substr(replace(uuid(), "-", ""), 0, 5)
  instance_name = var.instance_name != "" ? var.instance_name : "redc-${local.random_seed}"
  resource_prefix = "redc-${local.random_seed}"
}

resource "ctyun_vpc" "vpc_test" {
  name        = local.resource_prefix
  cidr        = "192.168.0.0/16"
  description = "redc vpc"
}

resource "ctyun_subnet" "subnet_test" {
  vpc_id      = ctyun_vpc.vpc_test.id
  name        = local.resource_prefix
  cidr        = "192.168.1.0/24"
  description = "redc subnet"
  dns = [
    "114.114.114.114",
    "8.8.8.8",
  ]
}

# 查询镜像列表
data "ctyun_images" "default" {
  name       = "Debian 13.1"
  visibility = "public"
  page_size  = 1
  page_no    = 1
}

# 查询规格列表
data "ctyun_ecs_flavors" "default" {
  cpu    = 2
  ram    = 4
  arch   = "x86"
  series = "S"
  type   = "CPU_S7"
}

resource "ctyun_security_group" "security_group_test" {
  vpc_id      = ctyun_vpc.vpc_test.id
  name        = local.resource_prefix
  description = "redc security group"
}

resource "ctyun_security_group_rule" "security_group_rule_egress_any" {
  security_group_id = ctyun_security_group.security_group_test.id
  direction         = "egress"
  action            = "accept"
  priority          = 50
  protocol          = "any"
  ether_type        = "ipv4"
  dest_cidr_ip      = "0.0.0.0/0"
  description       = "all egress"
}

resource "ctyun_security_group_rule" "security_group_rule_ingress_any" {
  security_group_id = ctyun_security_group.security_group_test.id
  direction         = "ingress"
  action            = "accept"
  priority          = 50
  protocol          = "any"
  ether_type        = "ipv4"
  dest_cidr_ip      = "0.0.0.0/0"
  description       = "all ingress"
}

resource "ctyun_ecs" "test" {
  instance_name    = local.instance_name
  display_name     = local.instance_name
  flavor_id        = var.instance_flavor_id != "" ? var.instance_flavor_id : data.ctyun_ecs_flavors.default.flavors[0].id
  image_id         = var.instance_image_id != "" ? var.instance_image_id : data.ctyun_images.default.images[0].id
  az_name          = var.availability_zone
  system_disk_type = "sata"
  system_disk_size = 40
  vpc_id           = ctyun_vpc.vpc_test.id
  subnet_id        = ctyun_subnet.subnet_test.id
  password         = var.instance_password
  cycle_type       = "on_demand"
  bandwidth        = 100
  security_group_ids = [ctyun_security_group.security_group_test.id]
  user_data = base64encode(file("userdata"))
}
