#!/bin/bash
# redc-plugin-upload-r2: post-apply hook
# 将场景目录下的配置文件通过 rclone 上传到 Cloudflare R2
#
# 依赖: rclone (已配置 r2 remote)
# 环境变量:
#   REDC_CASE_PATH  - 场景目录
#   REDC_PLUGIN_CONFIG_BUCKET_NAME - R2 桶名 (可选)
#   REDC_PLUGIN_CONFIG_BUCKET_PATH - R2 桶内路径 (可选)
#   REDC_PLUGIN_CONFIG_FILENAME    - 文件名 (可选)

set -euo pipefail

CASE_PATH="${REDC_CASE_PATH:-}"

if [ -z "$CASE_PATH" ]; then
    echo "[upload-r2] ERROR: REDC_CASE_PATH is empty"
    exit 1
fi

if ! command -v rclone &>/dev/null; then
    echo "[upload-r2] ERROR: rclone not found, please install rclone and configure r2 remote"
    exit 1
fi

# --- 读取参数 ---
read_tfvar() {
    local key="$1"
    local file="$CASE_PATH/terraform.tfvars"
    if [ -f "$file" ]; then
        grep -E "^\\s*${key}\\s*=" "$file" 2>/dev/null | head -1 | sed 's/[^=]*=\s*//; s/^"//; s/"$//' || true
    fi
}

FILENAME="${REDC_PLUGIN_CONFIG_FILENAME:-$(read_tfvar filename)}"
FILENAME="${FILENAME:-default-config.yaml}"

BUCKET_NAME="${REDC_PLUGIN_CONFIG_BUCKET_NAME:-$(read_tfvar buckets_name)}"
BUCKET_NAME="${BUCKET_NAME:-test}"

BUCKET_PATH="${REDC_PLUGIN_CONFIG_BUCKET_PATH:-$(read_tfvar buckets_path)}"
# 清理路径
BUCKET_PATH=$(echo "$BUCKET_PATH" | sed 's:^/::; s:/$::')
if [ -n "$BUCKET_PATH" ]; then
    BUCKET_PATH="${BUCKET_PATH}/"
fi

FILE_PATH="$CASE_PATH/$FILENAME"

if [ ! -f "$FILE_PATH" ]; then
    echo "[upload-r2] WARNING: file not found: $FILE_PATH, skipping"
    exit 0
fi

REMOTE_DIR="r2:${BUCKET_NAME}/${BUCKET_PATH}"

# 先删除旧文件（忽略错误）
echo "[upload-r2] deleting old file: ${REMOTE_DIR}${FILENAME}"
cd "$CASE_PATH"
rclone deletefile "${REMOTE_DIR}${FILENAME}" 2>/dev/null || true

# 上传
echo "[upload-r2] uploading: $FILENAME -> $REMOTE_DIR"
rclone copy "$FILENAME" "$REMOTE_DIR"

echo "[upload-r2] upload completed: ${REMOTE_DIR}${FILENAME}"

# Output for GUI display
echo "REDC_OUTPUT:r2_path=${REMOTE_DIR}${FILENAME}"
