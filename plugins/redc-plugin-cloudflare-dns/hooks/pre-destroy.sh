#!/bin/bash
# redc-plugin-cloudflare-dns: pre-destroy hook
# 销毁场景前删除 Cloudflare DNS A 记录（如果启用了 cleanup_on_destroy）
#
# 依赖: jq, curl

set -euo pipefail

CLEANUP="${REDC_PLUGIN_CONFIG_CLEANUP_ON_DESTROY:-true}"
if [ "$CLEANUP" != "true" ]; then
    echo "[cf-dns] cleanup_on_destroy is disabled, skipping"
    exit 0
fi

CF_EMAIL="${REDC_PLUGIN_CONFIG_CF_EMAIL:-${CF_EMAIL:-${CF_API_EMAIL:-}}}"
CF_API_KEY="${REDC_PLUGIN_CONFIG_CF_API_KEY:-${CF_API_KEY:-${CF_KEY:-}}}"

if [ -z "$CF_EMAIL" ] || [ -z "$CF_API_KEY" ]; then
    echo "[cf-dns] WARNING: CF credentials not configured, skipping cleanup"
    exit 0
fi

# 读取保存的状态
STATE_FILE="${REDC_PLUGIN_DIR}/.dns-state-${REDC_CASE_NAME:-unknown}"
if [ ! -f "$STATE_FILE" ]; then
    echo "[cf-dns] no DNS state found for this case, skipping cleanup"
    exit 0
fi

source "$STATE_FILE"

if [ -z "${ZONE_ID:-}" ] || [ -z "${RECORD_NAME:-}" ]; then
    echo "[cf-dns] incomplete state, skipping cleanup"
    exit 0
fi

CF_API="https://api.cloudflare.com/client/v4"

cf_request() {
    local method="$1" url="$2"
    curl -s -X "$method" -H "X-Auth-Email: $CF_EMAIL" -H "X-Auth-Key: $CF_API_KEY" -H "Content-Type: application/json" "$url"
}

# 查找 A 记录
RECORD_RESP=$(cf_request GET "${CF_API}/zones/${ZONE_ID}/dns_records?type=A&name=${RECORD_NAME}")
RECORD_ID=$(echo "$RECORD_RESP" | jq -r '.result[0].id // empty')

if [ -z "$RECORD_ID" ]; then
    echo "[cf-dns] A record '$RECORD_NAME' not found, nothing to delete"
else
    echo "[cf-dns] deleting A record: $RECORD_NAME (ID: $RECORD_ID)"
    RESULT=$(cf_request DELETE "${CF_API}/zones/${ZONE_ID}/dns_records/${RECORD_ID}")
    SUCCESS=$(echo "$RESULT" | jq -r '.success // false')
    if [ "$SUCCESS" = "true" ]; then
        echo "[cf-dns] DNS record deleted: $RECORD_NAME"
    else
        echo "[cf-dns] WARNING: failed to delete DNS record"
        echo "$RESULT" | jq -r '.errors[].message // empty' 2>/dev/null || true
    fi
fi

# 清理状态文件
rm -f "$STATE_FILE"
echo "[cf-dns] cleanup completed"
