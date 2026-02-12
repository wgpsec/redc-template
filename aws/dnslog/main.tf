provider "aws" {
  region = "ap-east-1"
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "tls_private_key" "pte_ssh" {
  algorithm = "ED25519"
}

resource "aws_key_pair" "pte_key" {
  key_name   = "pte-dnslog-key-${random_id.suffix.hex}"
  public_key = tls_private_key.pte_ssh.public_key_openssh
}

resource "aws_security_group" "pte_open_all" {
  name        = "pte-open-all-dnslog-${random_id.suffix.hex}"
  description = "Allow all inbound and outbound"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "dnslog" {
  ami                    = "ami-01c9cc5554738042c"
  instance_type          = "t4g.nano"
  vpc_security_group_ids = [aws_security_group.pte_open_all.id]
  key_name               = aws_key_pair.pte_key.key_name

  root_block_device {
    volume_type = "gp3"
    volume_size = 18
  }

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
sudo unzip static.zip

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

resource "local_file" "pte_private_key" {
  filename        = "./pte-dnslog-key.pem"
  content         = tls_private_key.pte_ssh.private_key_openssh
  file_permission = "0600"
}
