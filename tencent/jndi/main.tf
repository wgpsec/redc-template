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
  instance_name              = "jndi"
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

sudo wget -O jdk-8u321-linux-x64.tar.gz '${var.github_proxy}/No-Github/Archive/releases/download/1.0.5/jdk-8u321-linux-x64.tar.gz'
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

sudo wget -O JNDIExploit_feihong.zip '${var.github_proxy}/No-Github/Archive/blob/master/JNDI/JNDIExploit_feihong.zip'
sudo mkdir -p /root/JNDIExploit_feihong
sudo unzip JNDIExploit_feihong.zip -d /root/JNDIExploit_feihong
sudo rm -f JNDIExploit_feihong.zip
sudo mv /tmp/JNDIExploit_feihong .

sudo wget -O JNDIExploit_0x727.zip '${var.github_proxy}/No-Github/Archive/blob/master/JNDI/JNDIExploit_0x727.zip'
sudo mkdir -p /root/JNDIExploit_0x727
sudo unzip JNDIExploit_0x727.zip -d /root/JNDIExploit_0x727
sudo rm -f JNDIExploit_0x727.zip
sudo mv /tmp/JNDIExploit_0x727 .

sudo wget -O java-chains-1.4.4.tar.gz '${var.github_proxy}/vulhub/java-chains/releases/download/1.4.4/java-chains-1.4.4.tar.gz'
sudo mkdir -p /root/java-chains
sudo tar -zxvf java-chains-1.4.4.tar.gz -C /root/java-chains
sudo rm -f java-chains-1.4.4.tar.gz

sudo wget -O /root/JNDI-Injection-Exploit-1.0-SNAPSHOT-all.jar '${var.github_proxy}/welk1n/JNDI-Injection-Exploit/releases/download/v1.0/JNDI-Injection-Exploit-1.0-SNAPSHOT-all.jar'

sudo wget -O /root/boot-2.5.0.jar '${var.github_proxy}/ReaJason/MemShellParty/releases/download/v2.5.0/boot-2.5.0.jar'

sudo apt-get -y install lrzsz
sudo sleep 1
sudo apt-get install -y tmux
sudo apt-get -y install wget
sudo apt-get -y install unzip
sudo apt-get install -y screen
sudo wget -O simplehttpserver_0.0.6_linux_amd64.zip '${var.github_proxy}/projectdiscovery/simplehttpserver/releases/download/v0.0.6/simplehttpserver_0.0.6_linux_amd64.zip'
sudo unzip simplehttpserver_0.0.6_linux_amd64.zip
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