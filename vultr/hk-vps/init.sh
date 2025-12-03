#!/usr/bin/env bash
set -ex

apt-get update
apt-get install -y curl
apt-get install -y lrzsz
apt-get install -y tmux

# f8x
curl -o f8x https://f8x.io/ && mv --force f8x /usr/local/bin/f8x && chmod +x /usr/local/bin/f8x

touch /tmp/IS_CI
# bash f8x -k
