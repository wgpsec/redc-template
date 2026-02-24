# 阿里云 ECS 实例
resource "alicloud_instance" "this" {
  instance_name        = var.instance_name
  instance_type        = var.instance_type
  image_id             = data.alicloud_images.default.images[0].id
  security_groups      = [alicloud_security_group.this.id]
  vswitch_id           = alicloud_vswitch.this.id
  system_disk_category = var.system_disk_category
  system_disk_size     = var.system_disk_size
  password             = var.instance_password
  user_data            = var.userdata != "" ? base64encode(var.userdata) : ""
  
  # 公网带宽
  internet_max_bandwidth_out = var.internet_max_bandwidth_out
  internet_charge_type       = "PayByTraffic"
  
  # 抢占式实例配置
  instance_charge_type = var.is_spot_instance ? "PostPaid" : "PrePaid"
  spot_strategy        = var.is_spot_instance ? "SpotAsPriceGo" : ""
  
  # 确保实例在 VPC 和交换机创建后再创建
  depends_on = [alicloud_vswitch.this]
}
