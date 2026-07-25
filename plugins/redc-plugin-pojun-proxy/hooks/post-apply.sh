#!/usr/bin/env bash
set -euo pipefail

fail() {
    echo "[pojun-proxy] ERROR: $*" >&2
    exit 1
}

read_tfvar() {
    local key="$1"
    local tfvars="$REDC_CASE_PATH/terraform.tfvars"
    if [[ -f "$tfvars" ]]; then
        sed -n -E "s/^[[:space:]]*${key}[[:space:]]*=[[:space:]]*\"([^\"]*)\"[[:space:]]*$/\\1/p" "$tfvars" | head -n 1
    fi
}

has_case_var() {
    local key="$1"
    [[ -n "$REDC_CASE_VARS" ]] && jq -e --arg key "$key" 'has($key)' <<<"$REDC_CASE_VARS" >/dev/null 2>&1
}

read_case_var() {
    local key="$1"
    jq -er --arg key "$key" '.[$key] | if type == "string" or type == "number" then tostring else empty end' <<<"$REDC_CASE_VARS"
}

sha256_file() {
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$1" | awk '{print $1}'
    elif command -v shasum >/dev/null 2>&1; then
        shasum -a 256 "$1" | awk '{print $1}'
    else
        fail "sha256sum or shasum is required"
    fi
}

sync_path() {
    local path="$1"
    if sync -f "$path" 2>/dev/null; then
        return
    fi
    sync
}

is_valid_ipv4() {
    local address="$1"
    local octets octet
    [[ "$address" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]] || return 1
    IFS='.' read -r -a octets <<<"$address"
    [[ ${#octets[@]} -eq 4 ]] || return 1
    for octet in "${octets[@]}"; do
        ((10#$octet >= 0 && 10#$octet <= 255)) || return 1
    done
}

command -v jq >/dev/null 2>&1 || fail "jq is required"

REDC_CASE_ID=${REDC_CASE_ID:-}
REDC_CASE_NAME=${REDC_CASE_NAME:-}
REDC_CASE_PATH=${REDC_CASE_PATH:-}
REDC_CASE_TEMPLATE=${REDC_CASE_TEMPLATE:-}
REDC_CASE_VARS=${REDC_CASE_VARS:-}
REDC_OUTPUT_JSON=${REDC_OUTPUT_JSON:-}

[[ -n "$REDC_CASE_PATH" ]] || fail "REDC_CASE_PATH is required"
[[ -d "$REDC_CASE_PATH" ]] || fail "REDC_CASE_PATH is not a directory"
[[ -n "$REDC_CASE_ID" ]] || fail "REDC_CASE_ID is required"
[[ -n "$REDC_OUTPUT_JSON" ]] || fail "REDC_OUTPUT_JSON is required"

if has_case_var port; then
    PORT=$(read_case_var port)
else
    PORT=$(read_tfvar port)
fi
if has_case_var password; then
    PASSWORD=$(read_case_var password)
else
    PASSWORD=$(read_tfvar password)
fi
CIPHER=chacha20-ietf-poly1305
POOL_ID=${REDC_PLUGIN_CONFIG_POOL_ID:-redc-${REDC_CASE_ID}-aliyun-proxy}

[[ -n "$PORT" ]] || fail "Shadowsocks port is required"
[[ -n "$PASSWORD" ]] || fail "Shadowsocks password is required"
[[ "$POOL_ID" =~ ^[A-Za-z0-9][A-Za-z0-9._:-]{0,127}$ ]] || fail "pool ID contains unsupported characters or is too long"
[[ "$PORT" =~ ^[0-9]+$ ]] || fail "Shadowsocks port must be numeric"
((10#$PORT >= 1 && 10#$PORT <= 65535)) || fail "Shadowsocks port must be between 1 and 65535"

IPS_JSON=$(jq -ce '
    (.ecs_ip.value // .public_ip.value // empty) as $value
    | if ($value | type) == "array" then $value
      elif ($value | type) == "string" then [$value]
      else empty
      end
' <<<"$REDC_OUTPUT_JSON") || fail "ecs_ip or public_ip output is required"
NODE_COUNT=$(jq -r 'length' <<<"$IPS_JSON")
[[ "$NODE_COUNT" -gt 0 ]] || fail "at least one proxy node is required"
UNIQUE_NODE_COUNT=$(jq -r 'unique | length' <<<"$IPS_JSON")
[[ "$UNIQUE_NODE_COUNT" -eq "$NODE_COUNT" ]] || fail "duplicate proxy nodes are not allowed"
while IFS= read -r IP; do
    is_valid_ipv4 "$IP" || fail "proxy node address is not a valid IPv4 literal"
done < <(jq -r '.[]' <<<"$IPS_JSON")

umask 077
BUNDLE_DIR="$REDC_CASE_PATH/pojun-proxy"
[[ ! -L "$BUNDLE_DIR" ]] || fail "bundle directory must not be a symlink"
mkdir -p "$BUNDLE_DIR"
chmod 0700 "$BUNDLE_DIR"

BUNDLE_FILE="$BUNDLE_DIR/bundle.json"
NODES_TMP=$(mktemp "$BUNDLE_DIR/.nodes.json.tmp.XXXXXX")
BUNDLE_TMP=$(mktemp "$BUNDLE_DIR/.bundle.json.tmp.XXXXXX")
cleanup() {
    rm -f "$NODES_TMP" "$BUNDLE_TMP"
}
trap cleanup EXIT HUP INT TERM

NODES_JSON=$(jq -cn \
    --argjson ips "$IPS_JSON" \
    --argjson port "$PORT" \
    --arg cipher "$CIPHER" \
    --arg password "$PASSWORD" \
    '$ips | to_entries | map({
        cipher: $cipher,
        name: ("redc-node-" + (("000" + ((.key + 1) | tostring))[-3:])),
        password: $password,
        port: $port,
        server: .value,
        type: "ss"
    })')
printf '%s' "$NODES_JSON" >"$NODES_TMP"
chmod 0600 "$NODES_TMP"

REVISION=$(sha256_file "$NODES_TMP")
GENERATED_AT=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
jq -n \
    --arg pool_id "$POOL_ID" \
    --arg generated_at "$GENERATED_AT" \
    --arg revision "$REVISION" \
    --arg case_id "$REDC_CASE_ID" \
    --arg case_name "$REDC_CASE_NAME" \
    --arg template "$REDC_CASE_TEMPLATE" \
    --argjson node_count "$NODE_COUNT" \
    --slurpfile nodes "$NODES_TMP" \
    '{
        schema_version: 1,
        pool_id: $pool_id,
        revision: $revision,
        generated_at: $generated_at,
        node_count: $node_count,
        nodes: $nodes[0],
        source: {
            kind: "redc_case",
            case_id: $case_id,
            case_name: $case_name,
            template: $template
        }
    }' >"$BUNDLE_TMP"
chmod 0600 "$BUNDLE_TMP"

sync_path "$BUNDLE_TMP"
mv -f "$BUNDLE_TMP" "$BUNDLE_FILE"
sync_path "$BUNDLE_DIR"
trap - EXIT HUP INT TERM
rm -f "$NODES_TMP"

echo "REDC_OUTPUT:pojun_proxy_bundle_file=$BUNDLE_FILE"
echo "REDC_OUTPUT:pojun_proxy_pool_id=$POOL_ID"
echo "REDC_OUTPUT:pojun_proxy_node_count=$NODE_COUNT"
echo "REDC_OUTPUT:pojun_proxy_revision=$REVISION"