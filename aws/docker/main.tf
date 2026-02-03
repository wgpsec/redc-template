provider "aws" {
  region = "ap-east-1"
}

resource "tls_private_key" "pte_ssh" {
  algorithm = "ED25519"
}

resource "aws_key_pair" "pte_key" {
  key_name   = "pte-docker-key"
  public_key = tls_private_key.pte_ssh.public_key_openssh
}

resource "aws_security_group" "pte_open_all" {
  name        = "pte-open-all-docker"
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

resource "aws_instance" "docker" {
  ami                    = "ami-01c6db7097043551d"
  instance_type          = "t3.medium"
  vpc_security_group_ids = [aws_security_group.pte_open_all.id]
  key_name               = aws_key_pair.pte_key.key_name

  root_block_device {
    volume_type = "gp3"
    volume_size = 18
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

sudo curl -o f8x https://f8x.ffffffff0x.com/ && mv --force f8x /usr/local/bin/f8x && chmod +x /usr/local/bin/f8x

sudo apt-get install -y python3-pip
sudo pip3 install trzsz --break-system-packages

sudo tmux new-session -s docker -d
sudo tmux send-keys -t docker:0 'touch /tmp/IS_CI;ulimit -n 65535;ulimit -u 65535;f8x -docker;history -c;exit' Enter
EOF

}

resource "local_file" "pte_private_key" {
  filename        = "./pte-docker-key.pem"
  content         = tls_private_key.pte_ssh.private_key_openssh
  file_permission = "0600"
}
