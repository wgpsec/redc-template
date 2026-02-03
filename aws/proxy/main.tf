provider "aws" {
  region = "ap-east-1"
}

resource "tls_private_key" "pte_ssh" {
  algorithm = "ED25519"
}

resource "aws_key_pair" "pte_key" {
  key_name   = "pte-proxy-key"
  public_key = tls_private_key.pte_ssh.public_key_openssh
}

resource "aws_security_group" "pte_open_all" {
  name        = "pte-open-all-proxy"
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

resource "aws_instance" "pte_node" {
  count                      = var.node
  ami                        = "ami-01c9cc5554738042c"
  instance_type              = "t4g.nano"
  vpc_security_group_ids     = [aws_security_group.pte_open_all.id]
  key_name                   = aws_key_pair.pte_key.key_name

  root_block_device {
    volume_type = "gp3"
    volume_size = 18
  }

  tags = {
    Name = "proxy"
  }

  user_data                   = <<EOF
#!/bin/bash
sudo apt-get update
sudo sleep 2
sudo apt-get install -y ca-certificates
sudo apt-get install -y shadowsocks-libev
sudo apt-get install -y wget
sudo apt-get install -y lrzsz
sudo apt-get install -y tmux
sudo sleep 1
sudo apt-get install -y ca-certificates
sudo apt-get install -y shadowsocks-libev
sudo apt-get install -y shadowsocks-libev
sudo apt-get install -y shadowsocks-libev
sudo apt-get install -y shadowsocks-libev
sudo whoami
sudo apt-get install -y shadowsocks-libev
sudo ls
sudo apt-get install -y shadowsocks-libev
sudo sleep 2
sudo apt-get install -y shadowsocks-libev
sudo echo '{' > /etc/shadowsocks-libev/config.json
sudo echo '    "server":["0.0.0.0"],' >> /etc/shadowsocks-libev/config.json
sudo echo "    \"server_port\":${var.port}," >> /etc/shadowsocks-libev/config.json
sudo echo '    "method":"chacha20-ietf-poly1305",' >> /etc/shadowsocks-libev/config.json
sudo echo "    \"password\":\"${var.password}\"," >> /etc/shadowsocks-libev/config.json
sudo echo '    "mode":"tcp_and_udp",' >> /etc/shadowsocks-libev/config.json
sudo echo '    "fast_open":false' >> /etc/shadowsocks-libev/config.json
sudo echo '}' >> /etc/shadowsocks-libev/config.json

sudo echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
sudo echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
sudo sysctl -p

sudo service shadowsocks-libev restart
EOF

}

resource "local_file" "pte_private_key" {
  filename        = "./pte-proxy-key.pem"
  content         = tls_private_key.pte_ssh.private_key_openssh
  file_permission = "0600"
}