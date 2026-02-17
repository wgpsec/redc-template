# 获取可用区 - 筛选支持指定实例规格的可用区
data "alicloud_zones" "default" {
  available_instance_type     = var.instance_type
  available_resource_creation = "VSwitch"
}

# 获取镜像 - 使用 Ubuntu 20.04
data "alicloud_images" "default" {
  most_recent = true
  owners      = "system"
  name_regex  = "^ubuntu_20.*64"
}

# 本地变量 - 可用区选择
locals {
  # 默认使用第一个可用区（索引 0）
  # 如果遇到 "Zone.NotOnSale" 错误，可以修改这里的索引值：
  # - 0: 第一个可用区
  # - 1: 第二个可用区
  # - 2: 第三个可用区
  # 以此类推
  zone_index = 0
}
