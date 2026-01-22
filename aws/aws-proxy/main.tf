provider "aws" {
  region = "ap-east-1"
}

resource "aws_instance" "pte_node" {
    count                      = "${var.node_count}"
    launch_template {
        id = "这个改成你的 launch_template id 值"
    }

    instance_type = "t4g.nano"

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
sudo echo "    \"server_port\":${var.ss_port}," >> /etc/shadowsocks-libev/config.json
sudo echo '    "method":"chacha20-ietf-poly1305",' >> /etc/shadowsocks-libev/config.json
sudo echo "    \"password\":\"${var.ss_pass}\"," >> /etc/shadowsocks-libev/config.json
sudo echo '    "mode":"tcp_and_udp",' >> /etc/shadowsocks-libev/config.json
sudo echo '    "fast_open":false' >> /etc/shadowsocks-libev/config.json
sudo echo '}' >> /etc/shadowsocks-libev/config.json

sudo echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
sudo echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
sudo sysctl -p

sudo service shadowsocks-libev restart
EOF

}