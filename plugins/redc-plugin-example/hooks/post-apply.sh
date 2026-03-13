#!/bin/bash
# RedC Plugin Hook: post-apply
# 场景部署完成后执行
#
# 可用环境变量:
#   REDC_HOOK_POINT    - 当前钩子点 (post-apply)
#   REDC_PLUGIN_NAME   - 插件名称
#   REDC_PLUGIN_DIR    - 插件目录路径
#   REDC_CASE_NAME     - 场景名称
#   REDC_CASE_PATH     - 场景路径
#   REDC_CASE_TEMPLATE - 场景模板类型
#   REDC_CASE_STATE    - 场景状态
#   REDC_OUTPUT_JSON   - Terraform 输出 (JSON)
#   REDC_PLUGIN_CONFIG - 插件配置 (JSON)
#   REDC_PLUGIN_CONFIG_NOTIFY_URL  - 配置: Webhook 地址
#   REDC_PLUGIN_CONFIG_ENABLE_LOG  - 配置: 是否记录日志

set -euo pipefail

echo "[redc-plugin-example] post-apply hook triggered"
echo "  Case: ${REDC_CASE_NAME:-unknown}"
echo "  Template: ${REDC_CASE_TEMPLATE:-unknown}"
echo "  State: ${REDC_CASE_STATE:-unknown}"

# 记录日志
if [ "${REDC_PLUGIN_CONFIG_ENABLE_LOG:-true}" = "true" ]; then
    LOG_FILE="${REDC_PLUGIN_DIR}/deploy.log"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] DEPLOYED case=${REDC_CASE_NAME} template=${REDC_CASE_TEMPLATE}" >> "$LOG_FILE"
    
    # 记录输出信息
    if [ -n "${REDC_OUTPUT_JSON:-}" ]; then
        echo "  outputs=${REDC_OUTPUT_JSON}" >> "$LOG_FILE"
    fi
    echo "[redc-plugin-example] log written to ${LOG_FILE}"
fi

# Webhook 通知
if [ -n "${REDC_PLUGIN_CONFIG_NOTIFY_URL:-}" ]; then
    echo "[redc-plugin-example] sending webhook notification..."
    curl -s -X POST "${REDC_PLUGIN_CONFIG_NOTIFY_URL}" \
        -H "Content-Type: application/json" \
        -d "{\"event\":\"deploy\",\"case\":\"${REDC_CASE_NAME}\",\"template\":\"${REDC_CASE_TEMPLATE}\",\"state\":\"${REDC_CASE_STATE}\"}" \
        --max-time 10 || echo "[redc-plugin-example] webhook failed (non-fatal)"
fi

echo "[redc-plugin-example] post-apply hook completed"
