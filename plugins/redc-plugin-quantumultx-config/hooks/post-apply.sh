#!/bin/bash
# redc-plugin-quantumultx-config: post-apply hook
# 从 Terraform outputs 获取 IP，结合 tfvars 中的 port/password 生成 QuantumultX 订阅文件
# 生成 Base64 编码的 ss:// URI 列表，可直接作为订阅链接内容使用
#
# 依赖: jq, base64
# 环境变量:
#   REDC_CASE_PATH   - 场景目录
#   REDC_OUTPUT_JSON  - Terraform 输出 (JSON)
#   REDC_PLUGIN_CONFIG_PORT       - SS 端口 (可选, 覆盖 tfvars)
#   REDC_PLUGIN_CONFIG_PASSWORD   - SS 密码 (可选, 覆盖 tfvars)
#   REDC_PLUGIN_CONFIG_FILENAME   - 输出文件名 (可选, 默认 quantumultx.txt)
#   REDC_PLUGIN_CONFIG_TAG_PREFIX - 节点名称前缀 (可选, 默认 proxy)

set -euo pipefail

CASE_PATH="${REDC_CASE_PATH:-}"
OUTPUT_JSON="${REDC_OUTPUT_JSON:-}"

if [ -z "$CASE_PATH" ]; then
    echo "[quantumultx-config] ERROR: REDC_CASE_PATH is empty"
    exit 1
fi

# --- 1. 解析 IP 列表 ---
IPS=""
if [ -n "$OUTPUT_JSON" ] && command -v jq &>/dev/null; then
    for key in ecs_ip public_ip; do
        val=$(echo "$OUTPUT_JSON" | jq -r ".[\"$key\"].value // empty" 2>/dev/null || true)
        if [ -n "$val" ]; then
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
    echo "[quantumultx-config] WARNING: no IPs found in outputs, skipping"
    exit 0
fi

echo "[quantumultx-config] found IPs: $(echo $IPS | tr '\n' ' ')"

# --- 2. 读取参数 ---
read_tfvar() {
    local key="$1"
    local file="$CASE_PATH/terraform.tfvars"
    if [ -f "$file" ]; then
        grep -E "^[[:space:]]*${key}[[:space:]]*=" "$file" 2>/dev/null | head -1 | sed 's/[^=]*=[[:space:]]*//; s/^"//; s/"$//' || true
    fi
}

PORT="${REDC_PLUGIN_CONFIG_PORT:-$(read_tfvar port)}"
PASSWORD="${REDC_PLUGIN_CONFIG_PASSWORD:-$(read_tfvar password)}"
FILENAME="${REDC_PLUGIN_CONFIG_FILENAME:-quantumultx.txt}"
TAG_PREFIX="${REDC_PLUGIN_CONFIG_TAG_PREFIX:-proxy}"

if [ -z "$PORT" ] || [ -z "$PASSWORD" ]; then
    echo "[quantumultx-config] DEBUG: CASE_PATH=$CASE_PATH"
    echo "[quantumultx-config] DEBUG: tfvars exists=$([ -f "$CASE_PATH/terraform.tfvars" ] && echo yes || echo no)"
    echo "[quantumultx-config] DEBUG: PORT=[$PORT] PASSWORD=[$PASSWORD]"
    if [ -f "$CASE_PATH/terraform.tfvars" ]; then
        echo "[quantumultx-config] DEBUG: tfvars content:"
        cat "$CASE_PATH/terraform.tfvars" 2>/dev/null || true
    fi
    echo "[quantumultx-config] ERROR: port or password not found (check tfvars or plugin config)"
    exit 1
fi

# --- 3. 生成 ss:// URI 列表并 Base64 编码 ---
CONFIG_FILE="$CASE_PATH/$FILENAME"
PLAIN_FILE="$CASE_PATH/${FILENAME%.txt}.plain.txt"

# 生成明文 ss:// URI 列表 (SIP002 格式)
# 格式: ss://BASE64(method:password)@server:port#TAG
METHOD="chacha20-ietf-poly1305"
USERINFO=$(printf '%s:%s' "$METHOD" "$PASSWORD" | base64 | tr -d '\n')

rm -f "$PLAIN_FILE"
INDEX=1
for ip in $IPS; do
    TAG="${TAG_PREFIX}-${INDEX}"
    ENCODED_TAG=$(printf '%s' "$TAG" | sed 's/ /%20/g; s/#/%23/g')
    echo "ss://${USERINFO}@${ip}:${PORT}#${ENCODED_TAG}" >> "$PLAIN_FILE"
    INDEX=$((INDEX + 1))
done

# 整体 Base64 编码生成订阅文件
base64 < "$PLAIN_FILE" | tr -d '\n' > "$CONFIG_FILE"

echo "[quantumultx-config] generated subscription file: $CONFIG_FILE"
echo "[quantumultx-config] generated plain URI file: $PLAIN_FILE"
echo "[quantumultx-config] IPs: $(echo $IPS | tr '\n' ', ')"
echo "[quantumultx-config] port=$PORT, tag_prefix=$TAG_PREFIX, filename=$FILENAME"
echo "[quantumultx-config] node count: $(echo "$IPS" | wc -w | tr -d ' ')"
echo ""
echo "[quantumultx-config] QuantumultX 导入方式:"
echo "  1. 将 $FILENAME 托管到 HTTP 服务器，在 QuantumultX [server_remote] 添加订阅链接"
echo "  2. 或直接复制 $PLAIN_FILE 中的 ss:// 链接手动添加节点"

# Output for GUI display
echo "REDC_OUTPUT:quantumultx_subscription_file=$CONFIG_FILE"
echo "REDC_OUTPUT:quantumultx_plain_file=$PLAIN_FILE"
echo "REDC_OUTPUT:quantumultx_node_count=$(echo "$IPS" | wc -w | tr -d ' ')"
