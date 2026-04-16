provider "aws" {
  region = var.region
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "tls_private_key" "pte_ssh" {
  algorithm = "ED25519"
}

resource "aws_key_pair" "pte_key" {
  key_name   = "pte-ec2-4g-key-${random_id.suffix.hex}"
  public_key = tls_private_key.pte_ssh.public_key_openssh
}

resource "aws_security_group" "pte_open_all" {
  name        = "pte-open-all-4g-${random_id.suffix.hex}"
  description = "Allow all inbound and outbound"

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_instance" "pte_node" {
  ami                    = var.ami
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.pte_open_all.id]
  key_name               = aws_key_pair.pte_key.key_name

  root_block_device {
    volume_type = "gp3"
    volume_size = var.volume_size
  }

  user_data = <<EOF
#!/bin/bash
sudo apt-get update
sudo apt-get install -y ca-certificates
sudo apt-get install -y curl
sudo apt-get install -y wget
sudo apt-get install -y lrzsz
sudo apt-get install -y tmux
sudo apt-get install -y unzip
sudo apt-get install -y git
sudo echo "set-option -g history-limit 20000" >> ~/.tmux.conf
sudo echo "set -g mouse on" >> ~/.tmux.conf

sudo echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
sudo echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
sudo sysctl -p

sudo apt-get install -y python3-pip
sudo pip3 install trzsz --break-system-packages

sudo iptables -t nat -A OUTPUT -d 169.254.169.254 -j DNAT --to-destination 127.0.0.1
EOF

}

resource "local_file" "pte_private_key" {
  filename        = "./pte-ec2-4g-key.pem"
  content         = tls_private_key.pte_ssh.private_key_openssh
  file_permission = "0600"
}
