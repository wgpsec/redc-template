# 火山引擎 ECS 实例
resource "volcengine_ecs_instance" "this" {
  instance_type      = var.instance_type
  image_id           = data.volcengine_images.default.images[0].image_id
  instance_name      = var.instance_name
  security_group_ids = [volcengine_security_group.this.id]
  subnet_id          = volcengine_subnet.this.id
  system_volume_size = var.system_disk_size
  system_volume_type = "ESSD_PL0"
  user_data          = var.userdata != "" ? base64encode(var.userdata) : ""
  password           = var.instance_password
}
