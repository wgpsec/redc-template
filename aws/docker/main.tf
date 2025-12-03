provider "aws" {
  region = "ap-east-1"
}

resource "aws_instance" "docker" {

    launch_template {
        id = "这个改成你的 launch_template id 值"
    }

    instance_type = "t3.medium"

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

sudo curl -o f8x https://f8x.ffffffff0x.com/ && mv --force f8x /usr/local/bin/f8x && chmod +x /usr/local/bin/f8x

sudo apt-get install -y python3-pip
sudo pip3 install trzsz --break-system-packages

sudo tmux new-session -s docker -d
sudo tmux send-keys -t docker:0 'touch /tmp/IS_CI;ulimit -n 65535;ulimit -u 65535;f8x -docker;history -c;exit' Enter
EOF

}
