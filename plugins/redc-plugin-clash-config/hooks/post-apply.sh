#!/bin/bash
# redc-plugin-clash-config: post-apply hook
# 从 Terraform outputs 获取 IP，结合 tfvars 中的 port/password 生成 Clash 配置
#
# 依赖: jq
# 环境变量:
#   REDC_CASE_PATH   - 场景目录
#   REDC_OUTPUT_JSON  - Terraform 输出 (JSON)
#   REDC_PLUGIN_CONFIG_PORT     - SS 端口 (可选, 覆盖 tfvars)
#   REDC_PLUGIN_CONFIG_PASSWORD - SS 密码 (可选, 覆盖 tfvars)
#   REDC_PLUGIN_CONFIG_FILENAME - 输出文件名 (可选, 默认 config.yaml)

set -euo pipefail

CASE_PATH="${REDC_CASE_PATH:-}"
OUTPUT_JSON="${REDC_OUTPUT_JSON:-}"

if [ -z "$CASE_PATH" ]; then
    echo "[clash-config] ERROR: REDC_CASE_PATH is empty"
    exit 1
fi

# --- 1. 解析 IP 列表 ---
IPS=""
if [ -n "$OUTPUT_JSON" ] && command -v jq &>/dev/null; then
    # 尝试 ecs_ip (array), 然后 public_ip (string 或 array)
    for key in ecs_ip public_ip; do
        val=$(echo "$OUTPUT_JSON" | jq -r ".[\"$key\"].value // empty" 2>/dev/null || true)
        if [ -n "$val" ]; then
            # 判断是数组还是字符串
            if echo "$val" | jq -e 'type == "array"' &>/dev/null; then
                IPS=$(echo "$val" | jq -r '.[]')
            else
                IPS="$val"
            fi
            break
        fi
    done
fi

if [ -z "$IPS" ]; then
    echo "[clash-config] WARNING: no IPs found in outputs, skipping"
    exit 0
fi

echo "[clash-config] found IPs: $(echo $IPS | tr '\n' ' ')"

# --- 2. 读取参数 ---
# 优先使用插件配置，否则从 tfvars 读取
read_tfvar() {
    local key="$1"
    local file="$CASE_PATH/terraform.tfvars"
    if [ -f "$file" ]; then
        grep -E "^[[:space:]]*${key}[[:space:]]*=" "$file" 2>/dev/null | head -1 | sed 's/[^=]*=[[:space:]]*//; s/^"//; s/"$//' || true
    fi
}

PORT="${REDC_PLUGIN_CONFIG_PORT:-$(read_tfvar port)}"
PASSWORD="${REDC_PLUGIN_CONFIG_PASSWORD:-$(read_tfvar password)}"
FILENAME="${REDC_PLUGIN_CONFIG_FILENAME:-$(read_tfvar filename)}"
FILENAME="${FILENAME:-config.yaml}"

if [ -z "$PORT" ] || [ -z "$PASSWORD" ]; then
    echo "[clash-config] DEBUG: CASE_PATH=$CASE_PATH"
    echo "[clash-config] DEBUG: tfvars exists=$([ -f "$CASE_PATH/terraform.tfvars" ] && echo yes || echo no)"
    echo "[clash-config] DEBUG: PORT=[$PORT] PASSWORD=[$PASSWORD]"
    if [ -f "$CASE_PATH/terraform.tfvars" ]; then
        echo "[clash-config] DEBUG: tfvars content:"
        cat "$CASE_PATH/terraform.tfvars" 2>/dev/null || true
    fi
    echo "[clash-config] ERROR: port or password not found (check tfvars or plugin config)"
    exit 1
fi

# --- 3. 生成 Clash 配置 ---
CONFIG_FILE="$CASE_PATH/$FILENAME"

cat > "$CONFIG_FILE" << 'HEADER'
mixed-port: 64277
allow-lan: true
bind-address: '*'
mode: rule
log-level: info
ipv6: false
external-controller: 127.0.0.1:9090

profile:
  store-selected: false
  store-fake-ip: true

dns:
  enable: false
  listen: 0.0.0.0:53
  default-nameserver:
    - 223.5.5.5
    - 119.29.29.29
  enhanced-mode: fake-ip
  fake-ip-range: 198.18.0.1/16
  nameserver:
    - 223.5.5.5
    - 119.29.29.29
    - tls://dns.rubyfish.cn:853
    - https://1.1.1.1/dns-query
    - dhcp://en0

proxies:
HEADER

# 写入 proxy 节点
for ip in $IPS; do
cat >> "$CONFIG_FILE" << EOF
  - name: "$ip"
    type: ss
    server: $ip
    port: $PORT
    cipher: chacha20-ietf-poly1305
    password: "$PASSWORD"

EOF
done

# 写入 proxy-groups
cat >> "$CONFIG_FILE" << 'GROUP_HEADER'
proxy-groups:
  - name: "test"
    type: load-balance
    proxies:
GROUP_HEADER

for ip in $IPS; do
    echo "      - $ip" >> "$CONFIG_FILE"
done

cat >> "$CONFIG_FILE" << 'FOOTER'
    url: 'http://www.gstatic.com/generate_204'
    interval: 2400
    strategy: round-robin

rules:
  - DOMAIN-SUFFIX,google.com,test
  - DOMAIN-KEYWORD,google,test
  - DOMAIN,google.com,test
  - GEOIP,CN,test
  - MATCH,test
  - SRC-IP-CIDR,192.168.1.201/32,DIRECT
  - IP-CIDR,127.0.0.0/8,DIRECT
  - DOMAIN-SUFFIX,ad.com,REJECT
FOOTER

echo "[clash-config] generated: $CONFIG_FILE ($(wc -l < "$CONFIG_FILE") lines)"
echo "[clash-config] IPs: $(echo $IPS | tr '\n' ', ')"
echo "[clash-config] port=$PORT, filename=$FILENAME"

# Output for GUI display
echo "REDC_OUTPUT:clash_config_file=$CONFIG_FILE"
echo "REDC_OUTPUT:clash_node_count=$(echo "$IPS" | wc -w | tr -d ' ')"
