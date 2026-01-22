provider "aws" {
  region = "ap-east-1"
}

resource "aws_instance" "dnslog" {

    launch_template {
        id = "这个改成你的 launch_template id 值"
    }

    instance_type = "t4g.nano"

    tags = {
      Name = "dnslog"
    }

    user_data                   = <<EOF
#!/bin/bash
sudo apt-get update
sudo apt-get install -y ca-certificates
sudo apt-get install -y curl
sudo apt-get install -y wget
sudo apt-get install -y lrzsz
sudo apt-get install -y tmux
sudo apt-get install -y unzip
sudo echo "set-option -g history-limit 20000" >> ~/.tmux.conf
sudo echo "set -g mouse on" >> ~/.tmux.conf

sudo echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
sudo echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
sudo sysctl -p

sudo wget -O pdnslog.tar.gz 'https://github.com/No-Github/pdnslog/releases/download/v1.0.0/pdnslog_1.0.0_linux_arm64.tar.gz'
sudo tar -xzf pdnslog.tar.gz
sudo chmod +x pdnslog

sudo wget -O index.html 'https://github.com/No-Github/pdnslog/releases/download/v1.0.0/index.html'
sudo wget -O static.zip 'https://github.com/No-Github/pdnslog/releases/download/v1.0.0/static.zip'
sudo unzip -o static.zip -d static

sudo touch config.toml
sudo echo '[front]' >> config.toml
sudo echo 'template = "index.html"' >> config.toml
sudo echo '[back]' >> config.toml
sudo echo 'listenhost = "0.0.0.0"' >> config.toml
sudo echo 'listenport = 80' >> config.toml
sudo echo "domains = [ \"${var.domain}\"]" >> config.toml
sudo echo 'cname = "www.baidu.com"' >> config.toml
sudo echo '[basicauth]' >> config.toml
sudo echo 'check = true' >> config.toml
sudo echo "username = \"${var.username}\"" >> config.toml
sudo echo "password = \"${var.password}\"" >> config.toml

sudo apt-get install -y python3-pip
sudo pip3 install trzsz --break-system-packages

sudo systemctl stop systemd-resolved

sudo tmux new-session -s dn -d
sudo tmux send-keys -t dn:0 './pdnslog' Enter

EOF

}
