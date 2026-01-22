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

sudo wget -O interactsh-server_1.2.4_linux_arm64.zip 'https://github.com/projectdiscovery/interactsh/releases/download/v1.2.4/interactsh-server_1.2.4_linux_arm64.zip'
sudo unzip interactsh-server_1.2.4_linux_arm64.zip
sudo chmod +x interactsh-server

sudo apt-get install -y python3-pip
sudo pip3 install trzsz --break-system-packages

sudo systemctl stop systemd-resolved

sudo sleep 60
sudo tmux new-session -s dn -d
sudo tmux send-keys -t dn:0 './interactsh-server -domain ${var.domain} -lip 0.0.0.0' Enter

EOF

}
