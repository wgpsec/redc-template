provider "random" {}

resource "random_password" "password" {
  length = 25
  special = true
  override_special = "_+-."
}

provider "tencentcloud" {
  secret_id  = var.tencentcloud_secret_id
  secret_key = var.tencentcloud_secret_key
  region     = "ap-beijing"
}

resource "tencentcloud_instance" "test" {
  instance_name              = "file"
  availability_zone          = "ap-beijing-7"
  image_id                   = "img-pi0ii46r"
  instance_type              = data.tencentcloud_instance_types.instance_types.instance_types.0.instance_type
  allocate_public_ip         = true
  internet_max_bandwidth_out = 50
  password = random_password.password.result
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

sudo apt-get -y install lrzsz
sudo sleep 1
sudo apt-get install -y tmux
sudo apt-get -y install wget
sudo apt-get -y install unzip
sudo apt-get install -y screen
sudo wget -O simplehttpserver_0.0.5_linux_amd64.tar.gz 'https://这里替换成你自己的静态下载地址'
sudo tar -zxvf simplehttpserver_0.0.5_linux_amd64.tar.gz
sudo mv --force simplehttpserver /usr/local/bin/simplehttpserver
sudo chmod +x /usr/local/bin/simplehttpserver

sudo apt-get install -y python3-pip
sudo pip3 install trzsz

EOF
  depends_on = [
    tencentcloud_security_group_rule.ingress,
    tencentcloud_security_group_rule.egress
  ]
}

resource "tencentcloud_security_group" "default" {
  name        = "file_security_group"
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