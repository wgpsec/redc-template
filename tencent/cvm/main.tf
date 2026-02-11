provider "tencentcloud" {
  secret_id  = var.tencentcloud_secret_id
  secret_key = var.tencentcloud_secret_key
  region     = "ap-beijing"
}

locals {
  password_seed      = replace(uuid(), "-", "")
  generated_password = format("%s_+%s", substr(local.password_seed, 0, 12), substr(local.password_seed, 12, 10))
  instance_password  = var.instance_password != "" ? var.instance_password : local.generated_password
}

resource "tencentcloud_instance" "test" {
  instance_name              = "cvm"
  availability_zone          = "ap-beijing-7"
  image_id                   = "img-pi0ii46r"
  instance_type              = data.tencentcloud_instance_types.instance_types.instance_types.0.instance_type
  allocate_public_ip         = true
  internet_max_bandwidth_out = 50
  password = local.instance_password
  orderly_security_groups    = [tencentcloud_security_group.default.id]
  user_data_raw              = <<EOF
#!/bin/bash
sudo apt-get update
sudo apt-get install -y ca-certificates
sudo apt-get -y install wget
sudo apt-get install -y curl
sudo apt-get install -y lrzsz
sudo apt-get install -y tmux
sudo apt-get install -y unzip
sudo echo "set-option -g history-limit 20000" >> ~/.tmux.conf
sudo echo "set -g mouse on" >> ~/.tmux.conf

sudo /usr/local/qcloud/stargate/admin/uninstall.sh
sudo /usr/local/qcloud/YunJing/uninst.sh
sudo /usr/local/qcloud/monitor/barad/admin/uninstall.sh

sudo apt-get install -y python3-pip
sudo pip3 install trzsz

EOF
  depends_on = [
    tencentcloud_security_group_rule.ingress,
    tencentcloud_security_group_rule.egress
  ]
}

resource "tencentcloud_security_group" "default" {
  name        = "jndi_security_group"
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
  memory_size    = 4
}