provider "tencentcloud" {
  secret_id  = var.tencentcloud_secret_id
  secret_key = var.tencentcloud_secret_key
  region     = "ap-beijing"
}

locals {
  password_seed      = replace(uuid(), "-", "")
  generated_password = format("%s_+%s", substr(local.password_seed, 0, 12), substr(local.password_seed, 12, 10))
  instance_password  = var.instance_password != "" ? var.instance_password : local.generated_password
  instance_name     = var.instance_name != "" ? var.instance_name : "nps_${local.random_suffix}"

  # 生成8位随机后缀用于资源命名，避免名称冲突
  random_suffix = substr(replace(uuid(), "-", ""), 0, 8)
}

resource "tencentcloud_instance" "test" {
  instance_name              = local.instance_name
  availability_zone          = "ap-beijing-7"
  image_id                   = "img-pi0ii46r"
  instance_type              = data.tencentcloud_instance_types.instance_types.instance_types.0.instance_type
  allocate_public_ip         = true
  internet_max_bandwidth_out = 50
  password                   = local.instance_password
  orderly_security_groups    = [tencentcloud_security_group.default.id]
  user_data_raw              = <<EOF
#!/bin/bash
sudo apt-get update
sudo sleep 2
sudo apt-get install -y ca-certificates
sudo apt-get -y install wget
sudo apt-get -y install unzip
sudo apt-get install -y lrzsz
sudo apt-get install -y tmux
sudo sleep 1
sudo apt-get -y install wget
sudo apt-get -y install unzip

sudo /usr/local/qcloud/stargate/admin/uninstall.sh
sudo /usr/local/qcloud/YunJing/uninst.sh
sudo /usr/local/qcloud/monitor/barad/admin/uninstall.sh

sudo wget -O linux_amd64_server.tar.gz '${var.github_proxy}/ehang-io/nps/releases/download/v0.26.10/linux_amd64_server.tar.gz'
sudo tar -zxvf linux_amd64_server.tar.gz
sudo chmod +x nps
sudo ./nps install
sudo ./nps install
sudo ./nps install
sudo ./nps install
sudo nps install

sudo echo "${var.base64_command}" | base64 -d > /etc/nps/conf/nps.conf

sudo nps start

sudo apt-get install -y python3-pip
sudo pip3 install trzsz

EOF
  depends_on = [
    tencentcloud_security_group_rule.ingress,
    tencentcloud_security_group_rule.egress
  ]
}

resource "tencentcloud_security_group" "default" {
  name        = "nps_security_group_${local.random_suffix}"
  description = "make it accessible for both production and stage ports"
  project_id  = 0
}

resource "tencentcloud_security_group_rule" "ingress" {
  security_group_id = tencentcloud_security_group.default.id
  type              = "ingress"
  cidr_ip           = "0.0.0.0/0"
  policy            = "accept"
  depends_on = [
    tencentcloud_security_group.default
  ]
}

resource "tencentcloud_security_group_rule" "egress" {
  security_group_id = tencentcloud_security_group.default.id
  type              = "egress"
  cidr_ip           = "0.0.0.0/0"
  policy            = "accept"
  depends_on = [
    tencentcloud_security_group.default
  ]
}

data "tencentcloud_instance_types" "instance_types" {
  filter {
    name   = "instance-family"
    values = ["S6"]
  }
  cpu_core_count = 2
  memory_size    = 2
}