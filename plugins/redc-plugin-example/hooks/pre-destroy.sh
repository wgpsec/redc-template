#!/bin/bash
# RedC Plugin Hook: pre-destroy
# 场景销毁前执行，可用于清理外部资源

set -euo pipefail

echo "[redc-plugin-example] pre-destroy hook triggered"
echo "  Case: ${REDC_CASE_NAME:-unknown}"

# 记录日志
if [ "${REDC_PLUGIN_CONFIG_ENABLE_LOG:-true}" = "true" ]; then
    LOG_FILE="${REDC_PLUGIN_DIR}/deploy.log"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] DESTROYING case=${REDC_CASE_NAME}" >> "$LOG_FILE"
fi

# Webhook 通知
if [ -n "${REDC_PLUGIN_CONFIG_NOTIFY_URL:-}" ]; then
    curl -s -X POST "${REDC_PLUGIN_CONFIG_NOTIFY_URL}" \
        -H "Content-Type: application/json" \
        -d "{\"event\":\"destroy\",\"case\":\"${REDC_CASE_NAME}\",\"template\":\"${REDC_CASE_TEMPLATE}\"}" \
        --max-time 10 || true
fi

echo "[redc-plugin-example] pre-destroy hook completed"
