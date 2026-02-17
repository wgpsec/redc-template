# 获取可用区
data "volcengine_zones" "default" {}

# 获取镜像 - 使用 veLinux
data "volcengine_images" "default" {
  os_type    = "Linux"
  visibility = "public"
  name_regex = "veLinux"
}
