provider "random" {}

resource "random_password" "password" {
  length = 25
  special = true
  override_special = "_+-."
}

resource "alicloud_instance" "instance" {
  security_groups            = alicloud_security_group.group.*.id
  instance_type              = "ecs.n1.small"
  image_id                   = "debian_11_7_x64_20G_alibase_20230907.vhd"
  instance_name              = "jndiserver"
  vswitch_id                 = alicloud_vswitch.vswitch.id
  system_disk_size           = 20
  internet_max_bandwidth_out = 100
  password = random_password.password.result
  user_data                  = <<EOF
#!/bin/bash
sudo apt-get update
sudo apt-get install -y ca-certificates
sudo apt-get -y install wget
sudo apt-get install -y curl
sudo apt-get install -y lrzsz
sudo apt-get install -y tmux
sudo apt-get install -y unzip
sudo apt-get install -y 7zip
sudo apt-get install -y p7zip-full
sudo echo "set-option -g history-limit 20000" >> ~/.tmux.conf
sudo echo "set -g mouse on" >> ~/.tmux.conf

sudo wget http://update.aegis.aliyun.com/download/uninstall.sh
sudo chmod +x uninstall.sh
sudo ./uninstall.sh
sudo wget http://update.aegis.aliyun.com/download/quartz_uninstall.sh
sudo chmod +x quartz_uninstall.sh
sudo ./quartz_uninstall.sh
sudo pkill aliyun-service
sudo rm -fr /etc/init.d/agentwatch /usr/sbin/aliyun-service
sudo rm -rf /usr/local/aegis*
sudo rm /usr/sbin/aliyun-service
sudo rm /lib/systemd/system/aliyun.service
sudo systemctl stop aliyun.service

sudo echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
sudo echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
sudo sysctl -p

sudo wget -O jdk-8u321-linux-x64.tar.gz 'https://这里替换成你自己的静态下载地址'
sudo tar -zxvf jdk-8u321-linux-x64.tar.gz
sudo rm -rf jdk-8u321-linux-x64.tar.gz

sudo mkdir -p /usr/local/java/
sudo mv --force jdk1.8.0_321 /usr/local/java
sudo ln -s /usr/local/java/jdk1.8.0_321/bin/java /usr/bin/java
sudo ln -s /usr/local/java/jdk1.8.0_321/bin/keytool /usr/bin/keytool

sudo echo "JAVA_HOME=/usr/local/java/jdk1.8.0_321" >> /etc/bash.bashrc
sudo echo "JRE_HOME=\$JAVA_HOME/jre" >> /etc/bash.bashrc
sudo echo "CLASSPATH=.:\$JAVA_HOME/lib:\$JRE_HOME/lib" >> /etc/bash.bashrc
sudo echo "PATH=\$JAVA_HOME/bin:\$PATH" >> /etc/bash.bashrc

sudo cat /usr/local/java/jdk1.8.0_321/jre/lib/security/java.security | sed 's/\jdk.tls.disabledAlgorithms=SSLv3\, TLSv1\, TLSv1.1\, RC4/jdk.tls.disabledAlgorithms=RC4/g' > /usr/local/java/jdk1.8.0_321/jre/lib/security/java.security.bak
sudo mv /usr/local/java/jdk1.8.0_321/jre/lib/security/java.security /usr/local/java/jdk1.8.0_321/jre/lib/security/java.security.bak2
sudo mv /usr/local/java/jdk1.8.0_321/jre/lib/security/java.security.bak /usr/local/java/jdk1.8.0_321/jre/lib/security/java.security

sudo wget -O JNDIExploit_feihong.zip 'https://这里替换成你自己的静态下载地址'
sudo mkdir -p /root/JNDIExploit_feihong
sudo unzip JNDIExploit_feihong.zip -d /root/JNDIExploit_feihong
sudo rm -f JNDIExploit_feihong.zip
sudo mv /tmp/JNDIExploit_feihong .

sudo wget -O JNDIExploit_0x727.zip 'https://这里替换成你自己的静态下载地址'
sudo mkdir -p /root/JNDIExploit_0x727
sudo unzip JNDIExploit_0x727.zip -d /root/JNDIExploit_0x727
sudo rm -f JNDIExploit_0x727.zip
sudo mv /tmp/JNDIExploit_0x727 .

sudo wget -O java-chains-1.4.1.7z.7z 'https://这里替换成你自己的静态下载地址'
sudo mkdir -p /root/java-chains
sudo 7z x java-chains-1.4.1.7z.7z -o/root/java-chains
sudo rm -f java-chains-1.4.1.7z

sudo wget -O /root/JNDI-Injection-Exploit-1.0-SNAPSHOT-all.jar 'https://这里替换成你自己的静态下载地址'

sudo wget -O /root/boot-2.1.0.jar 'https://这里替换成你自己的静态下载地址'

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
    alicloud_security_group.group
  ]

}
resource "alicloud_security_group" "group" {
  security_group_name        = "jndiserver_security_group"
  vpc_id      = alicloud_vpc.vpc.id
}

resource "alicloud_security_group_rule" "allow_all_tcp" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "1/65535"
  priority          = 1
  security_group_id = alicloud_security_group.group.id
  cidr_ip           = "0.0.0.0/0"
  depends_on = [
    alicloud_security_group.group
  ]
}

resource "alicloud_security_group_rule" "allow_all_udp" {
  type              = "ingress"
  ip_protocol       = "udp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "1/65535"
  priority          = 1
  security_group_id = alicloud_security_group.group.id
  cidr_ip           = "0.0.0.0/0"
  depends_on = [
    alicloud_security_group.group
  ]
}

resource "alicloud_vswitch" "vswitch" {
  vpc_id       = alicloud_vpc.vpc.id
  cidr_block   = "172.16.0.0/24"
  zone_id           = data.alicloud_zones.default.zones[0].id
  vswitch_name = "jndiserver_vswitch"
}

resource "alicloud_vpc" "vpc" {
  vpc_name   = "jndiserver_vpc"
  cidr_block = "172.16.0.0/16"
}

data "alicloud_zones" "default" {
  available_resource_creation = "VSwitch"
  available_instance_type = "ecs.n1.small"
}
