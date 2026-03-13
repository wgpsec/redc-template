#!/bin/bash
# redc-plugin-cloudflare-dns: post-apply hook
# 从 Terraform outputs 获取第一个 IP，更新 Cloudflare DNS A 记录
#
# 依赖: jq, curl
# 环境变量:
#   REDC_OUTPUT_JSON - Terraform 输出 (JSON)
#   REDC_PLUGIN_CONFIG_CF_EMAIL   - CF 邮箱
#   REDC_PLUGIN_CONFIG_CF_API_KEY - CF API Key
#   REDC_PLUGIN_CONFIG_DOMAIN     - 域名 (可选)
#   REDC_PLUGIN_CONFIG_RECORD_NAME - 记录名 (可选)

set -euo pipefail

CF_EMAIL="${REDC_PLUGIN_CONFIG_CF_EMAIL:-${CF_EMAIL:-${CF_API_EMAIL:-}}}"
CF_API_KEY="${REDC_PLUGIN_CONFIG_CF_API_KEY:-${CF_API_KEY:-${CF_KEY:-}}}"

if [ -z "$CF_EMAIL" ] || [ -z "$CF_API_KEY" ]; then
    echo "[cf-dns] WARNING: CF credentials not configured, skipping"
    exit 0
fi

# --- 1. 获取目标 IP ---
OUTPUT_JSON="${REDC_OUTPUT_JSON:-}"
TARGET_IP=""

if [ -n "$OUTPUT_JSON" ] && command -v jq &>/dev/null; then
    for key in ecs_ip public_ip; do
        val=$(echo "$OUTPUT_JSON" | jq -r ".[\"$key\"].value // empty" 2>/dev/null || true)
        if [ -n "$val" ]; then
            if echo "$val" | jq -e 'type == "array"' &>/dev/null; then
                TARGET_IP=$(echo "$val" | jq -r '.[0]')
            else
                TARGET_IP="$val"
            fi
            break
        fi
    done
fi

if [ -z "$TARGET_IP" ]; then
    echo "[cf-dns] WARNING: no IP found in outputs, skipping"
    exit 0
fi

echo "[cf-dns] target IP: $TARGET_IP"

# --- 2. 解析域名 ---
# 优先插件配置，其次场景参数
DOMAIN="${REDC_PLUGIN_CONFIG_DOMAIN:-}"
if [ -z "$DOMAIN" ]; then
    # 从场景参数解析 (REDC_CASE_VARS JSON)
    if [ -n "${REDC_CASE_VARS:-}" ] && command -v jq &>/dev/null; then
        DOMAIN=$(echo "$REDC_CASE_VARS" | jq -r '.domain // empty' 2>/dev/null || true)
    fi
fi

if [ -z "$DOMAIN" ]; then
    # 从 terraform.tfvars 读取
    if [ -f "${REDC_CASE_PATH:-}/terraform.tfvars" ]; then
        DOMAIN=$(grep -E '^[[:space:]]*domain[[:space:]]*=' "${REDC_CASE_PATH}/terraform.tfvars" 2>/dev/null | head -1 | sed 's/[^=]*=[[:space:]]*//; s/^"//; s/"$//' || true)
    fi
fi

if [ -z "$DOMAIN" ]; then
    echo "[cf-dns] WARNING: domain not configured, skipping"
    exit 0
fi

# Strip leading "a." prefix (redc adds it for dnslog scenarios)
DOMAIN=$(echo "$DOMAIN" | sed 's/^a\.//')

# 提取 zone 名称 (后两段)
extract_zone() {
    echo "$1" | awk -F. '{if(NF>=2) print $(NF-1)"."$NF; else print $0}'
}

ZONE=$(extract_zone "$DOMAIN")
RECORD_NAME="${REDC_PLUGIN_CONFIG_RECORD_NAME:-ns1.${ZONE}}"

echo "[cf-dns] zone=$ZONE record=$RECORD_NAME"

# --- 3. Cloudflare API ---
CF_API="https://api.cloudflare.com/client/v4"

cf_request() {
    local method="$1" url="$2" data="${3:-}"
    local args=(-s -X "$method" -H "X-Auth-Email: $CF_EMAIL" -H "X-Auth-Key: $CF_API_KEY" -H "Content-Type: application/json")
    if [ -n "$data" ]; then
        args+=(-d "$data")
    fi
    curl "${args[@]}" "$url"
}

# 获取 Zone ID
ZONE_RESP=$(cf_request GET "${CF_API}/zones?name=${ZONE}")
ZONE_ID=$(echo "$ZONE_RESP" | jq -r '.result[0].id // empty')

if [ -z "$ZONE_ID" ]; then
    echo "[cf-dns] ERROR: zone '$ZONE' not found"
    echo "$ZONE_RESP" | jq -r '.errors[].message // empty' 2>/dev/null || true
    exit 1
fi
echo "[cf-dns] zone ID: $ZONE_ID"

# 查找现有 A 记录
RECORD_RESP=$(cf_request GET "${CF_API}/zones/${ZONE_ID}/dns_records?type=A&name=${RECORD_NAME}")
RECORD_ID=$(echo "$RECORD_RESP" | jq -r '.result[0].id // empty')

PAYLOAD=$(cat <<EOF
{"type":"A","name":"${RECORD_NAME}","content":"${TARGET_IP}","ttl":3600,"proxied":false}
EOF
)

if [ -z "$RECORD_ID" ]; then
    # 创建新记录
    echo "[cf-dns] creating A record: $RECORD_NAME -> $TARGET_IP"
    RESULT=$(cf_request POST "${CF_API}/zones/${ZONE_ID}/dns_records" "$PAYLOAD")
else
    # 更新已有记录
    echo "[cf-dns] updating A record: $RECORD_NAME -> $TARGET_IP"
    RESULT=$(cf_request PUT "${CF_API}/zones/${ZONE_ID}/dns_records/${RECORD_ID}" "$PAYLOAD")
fi

SUCCESS=$(echo "$RESULT" | jq -r '.success // false')
if [ "$SUCCESS" = "true" ]; then
    echo "[cf-dns] DNS updated: $RECORD_NAME -> $TARGET_IP"
else
    echo "[cf-dns] ERROR: DNS update failed"
    echo "$RESULT" | jq -r '.errors[].message // empty' 2>/dev/null || true
    exit 1
fi

# 保存记录信息供 pre-destroy 使用
STATE_FILE="${REDC_PLUGIN_DIR}/.dns-state-${REDC_CASE_NAME:-unknown}"
cat > "$STATE_FILE" << EOF
ZONE_ID=$ZONE_ID
RECORD_NAME=$RECORD_NAME
EOF
echo "[cf-dns] state saved to $STATE_FILE"

# Output for GUI display
echo "REDC_OUTPUT:dns_record=${RECORD_NAME} -> ${TARGET_IP}"
