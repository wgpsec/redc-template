#!/usr/bin/env bash
set -euo pipefail

PLUGIN_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
HOOK="$PLUGIN_DIR/hooks/post-apply.sh"
TEST_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/redc-pojun-proxy-test.XXXXXX")
trap 'rm -rf "$TEST_ROOT"' EXIT

fail() {
    echo "FAIL: $*" >&2
    exit 1
}

file_mode() {
    if stat -f '%Lp' "$1" >/dev/null 2>&1; then
        stat -f '%Lp' "$1"
    else
        stat -c '%a' "$1"
    fi
}

sha256_file() {
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$1" | awk '{print $1}'
    else
        shasum -a 256 "$1" | awk '{print $1}'
    fi
}

sha256_text() {
    if command -v sha256sum >/dev/null 2>&1; then
        printf '%s' "$1" | sha256sum | awk '{print $1}'
    else
        printf '%s' "$1" | shasum -a 256 | awk '{print $1}'
    fi
}

test_generates_private_versioned_bundle() {
    local case_dir="$TEST_ROOT/valid-case"
    mkdir -p "$case_dir"
    cat > "$case_dir/terraform.tfvars" <<'TFVARS'
port = "8388"
password = "fixture-value"
TFVARS

    local output
    output=$(
        REDC_CASE_ID='4dfaf64b-426c-40ec-84d7-456d2a43dc67' \
        REDC_CASE_NAME='proxy-fixture' \
        REDC_CASE_PATH="$case_dir" \
        REDC_CASE_TEMPLATE='aliyun/proxy' \
        REDC_OUTPUT_JSON='{"ecs_ip":{"value":["203.0.113.10","203.0.113.11"]}}' \
        bash "$HOOK"
    )

    local bundle_dir="$case_dir/pojun-proxy"
    local bundle="$bundle_dir/bundle.json"
    [[ -f "$bundle" ]] || fail "bundle.json was not generated"
    [[ $(find "$bundle_dir" -maxdepth 1 -type f -print | wc -l | tr -d ' ') == "1" ]] || fail "bundle directory contains more than one final file"

    jq -e '
        .schema_version == 1 and
        .pool_id == "redc-4dfaf64b-426c-40ec-84d7-456d2a43dc67-aliyun-proxy" and
        .node_count == 2 and
        (.nodes | length) == 2 and
        .source.kind == "redc_case" and
        .source.case_id == "4dfaf64b-426c-40ec-84d7-456d2a43dc67" and
        .source.case_name == "proxy-fixture" and
        .source.template == "aliyun/proxy"
    ' "$bundle" >/dev/null || fail "bundle contract is invalid"

    local expected_digest actual_digest
    expected_digest=$(sha256_text "$(jq -c '.nodes' "$bundle")")
    actual_digest=$(jq -r '.revision' "$bundle")
    [[ "$actual_digest" == "$expected_digest" ]] || fail "bundle revision does not match canonical nodes"

    jq -e '.nodes[0].server == "203.0.113.10" and .nodes[1].server == "203.0.113.11" and .nodes[0].password == "fixture-value" and (.nodes | all(.type == "ss" and .cipher == "chacha20-ietf-poly1305"))' "$bundle" >/dev/null || fail "proxy nodes are invalid"
    jq -e 'has("mixed-port") or has("allow-lan") or has("external-controller") or has("rules") or has("proxy-groups")' "$bundle" >/dev/null && fail "bundle contains forbidden inbound or routing configuration"

    [[ $(file_mode "$bundle_dir") == "700" ]] || fail "bundle directory is not mode 0700"
    [[ $(file_mode "$bundle") == "600" ]] || fail "bundle is not mode 0600"

    grep -q "REDC_OUTPUT:pojun_proxy_bundle_file=$bundle" <<<"$output" || fail "bundle output is missing"
    grep -q 'REDC_OUTPUT:pojun_proxy_node_count=2' <<<"$output" || fail "node count output is missing"
    grep -q "REDC_OUTPUT:pojun_proxy_revision=$expected_digest" <<<"$output" || fail "revision output is missing"
    if grep -q 'fixture-value' <<<"$output"; then
        fail "hook output leaked the proxy password"
    fi
}

test_rejects_duplicate_nodes_without_replacing_bundle() {
    local case_dir="$TEST_ROOT/duplicate-case"
    mkdir -p "$case_dir"
    cat > "$case_dir/terraform.tfvars" <<'TFVARS'
port = "8388"
password = "fixture-value"
TFVARS

    REDC_CASE_ID='duplicate-fixture' \
    REDC_CASE_NAME='duplicate-fixture' \
    REDC_CASE_PATH="$case_dir" \
    REDC_CASE_TEMPLATE='aliyun/proxy' \
    REDC_OUTPUT_JSON='{"ecs_ip":{"value":["203.0.113.20"]}}' \
    bash "$HOOK" >/dev/null

    local bundle="$case_dir/pojun-proxy/bundle.json"
    local original_revision
    original_revision=$(jq -r '.revision' "$bundle")

    if REDC_CASE_ID='duplicate-fixture' \
        REDC_CASE_NAME='duplicate-fixture' \
        REDC_CASE_PATH="$case_dir" \
        REDC_CASE_TEMPLATE='aliyun/proxy' \
        REDC_OUTPUT_JSON='{"ecs_ip":{"value":["203.0.113.20","203.0.113.20"]}}' \
        bash "$HOOK" >/dev/null 2>&1; then
        fail "duplicate proxy nodes were accepted"
    fi

    [[ $(jq -r '.revision' "$bundle") == "$original_revision" ]] || fail "invalid update replaced last-known-good bundle"
    [[ $(find "$case_dir/pojun-proxy" -name '.*.tmp.*' -print | wc -l | tr -d ' ') == "0" ]] || fail "failed update left temporary files"
}

test_rejects_invalid_node_address() {
    local case_dir="$TEST_ROOT/invalid-address-case"
    mkdir -p "$case_dir"
    cat > "$case_dir/terraform.tfvars" <<'TFVARS'
port = "8388"
password = "fixture-value"
TFVARS

    if REDC_CASE_ID='invalid-address-fixture' \
        REDC_CASE_NAME='invalid-address-fixture' \
        REDC_CASE_PATH="$case_dir" \
        REDC_CASE_TEMPLATE='aliyun/proxy' \
        REDC_OUTPUT_JSON='{"ecs_ip":{"value":["999.0.0.1"]}}' \
        bash "$HOOK" >/dev/null 2>&1; then
        fail "invalid proxy node address was accepted"
    fi
    [[ ! -e "$case_dir/pojun-proxy/bundle.json" ]] || fail "invalid address produced a bundle"
}

test_rejects_invalid_proxy_port() {
    local case_dir="$TEST_ROOT/invalid-port-case"
    mkdir -p "$case_dir"
    cat > "$case_dir/terraform.tfvars" <<'TFVARS'
port = "70000"
password = "fixture-value"
TFVARS

    if REDC_CASE_ID='invalid-port-fixture' \
        REDC_CASE_NAME='invalid-port-fixture' \
        REDC_CASE_PATH="$case_dir" \
        REDC_CASE_TEMPLATE='aliyun/proxy' \
        REDC_OUTPUT_JSON='{"ecs_ip":{"value":["203.0.113.30"]}}' \
        bash "$HOOK" >/dev/null 2>&1; then
        fail "invalid proxy port was accepted"
    fi
    [[ ! -e "$case_dir/pojun-proxy/bundle.json" ]] || fail "invalid port produced a bundle"
}

test_rejects_invalid_pool_id() {
    local case_dir="$TEST_ROOT/invalid-pool-id-case"
    mkdir -p "$case_dir"
    cat > "$case_dir/terraform.tfvars" <<'TFVARS'
port = "8388"
password = "fixture-value"
TFVARS

    if REDC_CASE_ID='invalid-pool-id-fixture' \
        REDC_CASE_NAME='invalid-pool-id-fixture' \
        REDC_CASE_PATH="$case_dir" \
        REDC_CASE_TEMPLATE='aliyun/proxy' \
        REDC_OUTPUT_JSON='{"ecs_ip":{"value":["203.0.113.40"]}}' \
        REDC_PLUGIN_CONFIG_POOL_ID='../invalid pool' \
        bash "$HOOK" >/dev/null 2>&1; then
        fail "invalid pool ID was accepted"
    fi
    [[ ! -e "$case_dir/pojun-proxy/bundle.json" ]] || fail "invalid pool ID produced a bundle"
}

test_case_vars_override_template_defaults() {
    local case_dir="$TEST_ROOT/case-vars-override"
    mkdir -p "$case_dir"
    cat > "$case_dir/terraform.tfvars" <<'TFVARS'
port = "8388"
password = "template-fixture"
TFVARS

    local output
    output=$(
        REDC_CASE_ID='case-vars-fixture' \
        REDC_CASE_NAME='case-vars-fixture' \
        REDC_CASE_PATH="$case_dir" \
        REDC_CASE_TEMPLATE='aliyun/proxy' \
        REDC_CASE_VARS='{"port":"9443","password":"runtime-fixture"}' \
        REDC_OUTPUT_JSON='{"ecs_ip":{"value":["203.0.113.50"]}}' \
        bash "$HOOK"
    )

    local bundle="$case_dir/pojun-proxy/bundle.json"
    jq -e '.nodes[0].port == 9443 and .nodes[0].password == "runtime-fixture"' "$bundle" >/dev/null || fail "runtime vars did not override terraform.tfvars"
    if grep -Eq 'template-fixture|runtime-fixture' <<<"$output"; then
        fail "hook output leaked a proxy password"
    fi
}

test_uses_scenario_cipher_contract() {
    local case_dir="$TEST_ROOT/fixed-cipher-case"
    mkdir -p "$case_dir"
    cat > "$case_dir/terraform.tfvars" <<'TFVARS'
port = "8388"
password = "fixture-value"
TFVARS

    REDC_CASE_ID='fixed-cipher-fixture' \
    REDC_CASE_NAME='fixed-cipher-fixture' \
    REDC_CASE_PATH="$case_dir" \
    REDC_CASE_TEMPLATE='aliyun/proxy' \
    REDC_OUTPUT_JSON='{"ecs_ip":{"value":["203.0.113.60"]}}' \
    REDC_PLUGIN_CONFIG_CIPHER='aes-256-gcm' \
    bash "$HOOK" >/dev/null

    local bundle="$case_dir/pojun-proxy/bundle.json"
    jq -e '.nodes[0].cipher == "chacha20-ietf-poly1305"' "$bundle" >/dev/null || fail "bundle did not use the scenario cipher"
    if grep -q 'aes-256-gcm' "$bundle"; then
        fail "undeclared cipher configuration changed the bundle"
    fi
}

test_ignores_undeclared_plugin_credentials() {
    local case_dir="$TEST_ROOT/undeclared-plugin-credentials-case"
    mkdir -p "$case_dir"
    cat > "$case_dir/terraform.tfvars" <<'TFVARS'
port = "8388"
password = "case-fixture"
TFVARS

    REDC_CASE_ID='undeclared-plugin-credentials-fixture' \
    REDC_CASE_NAME='undeclared-plugin-credentials-fixture' \
    REDC_CASE_PATH="$case_dir" \
    REDC_CASE_TEMPLATE='aliyun/proxy' \
    REDC_OUTPUT_JSON='{"ecs_ip":{"value":["203.0.113.65"]}}' \
    REDC_PLUGIN_CONFIG_PORT='9443' \
    REDC_PLUGIN_CONFIG_PASSWORD='plugin-fixture' \
    bash "$HOOK" >/dev/null

    local bundle="$case_dir/pojun-proxy/bundle.json"
    jq -e '.nodes[0].port == 8388 and .nodes[0].password == "case-fixture"' "$bundle" >/dev/null || fail "undeclared plugin credentials changed the bundle"
    if grep -Eq '9443|plugin-fixture' "$bundle"; then
        fail "undeclared plugin credentials were persisted"
    fi
}

test_accepts_public_ip_string_output() {
    local case_dir="$TEST_ROOT/public-ip-string-case"
    mkdir -p "$case_dir"
    cat > "$case_dir/terraform.tfvars" <<'TFVARS'
port = "8388"
password = "fixture-value"
TFVARS

    REDC_CASE_ID='public-ip-string-fixture' \
    REDC_CASE_NAME='public-ip-string-fixture' \
    REDC_CASE_PATH="$case_dir" \
    REDC_CASE_TEMPLATE='aliyun/proxy' \
    REDC_OUTPUT_JSON='{"public_ip":{"value":"203.0.113.70"}}' \
    bash "$HOOK" >/dev/null

    jq -e '.node_count == 1 and .nodes[0].server == "203.0.113.70"' "$case_dir/pojun-proxy/bundle.json" >/dev/null || fail "public_ip string did not produce one node"
}

test_rejects_empty_node_output() {
    local case_dir="$TEST_ROOT/empty-node-case"
    mkdir -p "$case_dir"
    cat > "$case_dir/terraform.tfvars" <<'TFVARS'
port = "8388"
password = "fixture-value"
TFVARS

    if REDC_CASE_ID='empty-node-fixture' \
        REDC_CASE_NAME='empty-node-fixture' \
        REDC_CASE_PATH="$case_dir" \
        REDC_CASE_TEMPLATE='aliyun/proxy' \
        REDC_OUTPUT_JSON='{"ecs_ip":{"value":[]}}' \
        bash "$HOOK" >/dev/null 2>&1; then
        fail "empty proxy node output was accepted"
    fi
    [[ ! -e "$case_dir/pojun-proxy/bundle.json" ]] || fail "empty proxy node output produced a bundle"
}

test_rejects_empty_proxy_password() {
    local case_dir="$TEST_ROOT/empty-password-case"
    mkdir -p "$case_dir"
    cat > "$case_dir/terraform.tfvars" <<'TFVARS'
port = "8388"
password = ""
TFVARS

    if REDC_CASE_ID='empty-password-fixture' \
        REDC_CASE_NAME='empty-password-fixture' \
        REDC_CASE_PATH="$case_dir" \
        REDC_CASE_TEMPLATE='aliyun/proxy' \
        REDC_OUTPUT_JSON='{"ecs_ip":{"value":["203.0.113.80"]}}' \
        bash "$HOOK" >/dev/null 2>&1; then
        fail "empty proxy password was accepted"
    fi
    [[ ! -e "$case_dir/pojun-proxy/bundle.json" ]] || fail "empty proxy password produced a bundle"
}

test_rejects_bundle_directory_symlink() {
    local case_dir="$TEST_ROOT/symlink-case"
    local outside_dir="$TEST_ROOT/symlink-outside"
    mkdir -p "$case_dir" "$outside_dir"
    ln -s "$outside_dir" "$case_dir/pojun-proxy"
    cat > "$case_dir/terraform.tfvars" <<'TFVARS'
port = "8388"
password = "fixture-value"
TFVARS

    if REDC_CASE_ID='symlink-fixture' \
        REDC_CASE_NAME='symlink-fixture' \
        REDC_CASE_PATH="$case_dir" \
        REDC_CASE_TEMPLATE='aliyun/proxy' \
        REDC_OUTPUT_JSON='{"ecs_ip":{"value":["203.0.113.90"]}}' \
        bash "$HOOK" >/dev/null 2>&1; then
        fail "bundle directory symlink was accepted"
    fi
    [[ ! -e "$outside_dir/bundle.json" ]] || fail "bundle escaped through a directory symlink"
}

test_node_refresh_keeps_pool_id_and_changes_revision() {
    local case_dir="$TEST_ROOT/node-refresh-case"
    mkdir -p "$case_dir"
    cat > "$case_dir/terraform.tfvars" <<'TFVARS'
port = "8388"
password = "fixture-value"
TFVARS

    REDC_CASE_ID='node-refresh-fixture' \
    REDC_CASE_NAME='node-refresh-fixture' \
    REDC_CASE_PATH="$case_dir" \
    REDC_CASE_TEMPLATE='aliyun/proxy' \
    REDC_OUTPUT_JSON='{"ecs_ip":{"value":["203.0.113.100"]}}' \
    bash "$HOOK" >/dev/null

    local bundle="$case_dir/pojun-proxy/bundle.json"
    local original_pool original_revision
    original_pool=$(jq -r '.pool_id' "$bundle")
    original_revision=$(jq -r '.revision' "$bundle")

    REDC_CASE_ID='node-refresh-fixture' \
    REDC_CASE_NAME='node-refresh-fixture' \
    REDC_CASE_PATH="$case_dir" \
    REDC_CASE_TEMPLATE='aliyun/proxy' \
    REDC_OUTPUT_JSON='{"ecs_ip":{"value":["203.0.113.101"]}}' \
    bash "$HOOK" >/dev/null

    [[ $(jq -r '.pool_id' "$bundle") == "$original_pool" ]] || fail "node refresh changed the stable pool ID"
    [[ $(jq -r '.revision' "$bundle") != "$original_revision" ]] || fail "node refresh did not change the revision"
    jq -e '.nodes[0].server == "203.0.113.101"' "$bundle" >/dev/null || fail "node refresh did not replace the proxy list"
}

test_plugin_metadata_and_aliyun_binding() {
    local manifest="$PLUGIN_DIR/plugin.json"
    local case_manifest="$PLUGIN_DIR/../../aliyun/proxy/case.json"
    [[ -f "$manifest" ]] || fail "plugin.json is missing"
    jq -e '
        .name == "redc-plugin-pojun-proxy" and
        .version == "1.3.0" and
        .min_redc_version == "3.3.8" and
        .capabilities.hooks["post-apply"].type == "template" and
        .capabilities.hooks["post-apply"].template == "hooks/post-apply.tmpl" and
        .capabilities.hooks["post-apply"].output == "" and
        .capabilities.hooks["post-destroy"].type == "template" and
        .capabilities.hooks["post-destroy"].template == "hooks/post-destroy.tmpl" and
        .capabilities.hooks["post-destroy"].output == ""
    ' "$manifest" >/dev/null || fail "plugin.json contract is invalid"
    [[ -f "$PLUGIN_DIR/hooks/post-apply.tmpl" ]] || fail "template hook is missing"
    [[ -f "$PLUGIN_DIR/hooks/post-destroy.tmpl" ]] || fail "post-destroy template hook is missing"
    jq -e '
        (.redc_plugins | split(",") | index("redc-plugin-pojun-proxy")) != null and
        .version == "1.4.0"
    ' "$case_manifest" >/dev/null || fail "aliyun/proxy is not bound to the PoJun proxy plugin"
}

test_generates_private_versioned_bundle
test_rejects_duplicate_nodes_without_replacing_bundle
test_rejects_invalid_node_address
test_rejects_invalid_proxy_port
test_rejects_invalid_pool_id
test_case_vars_override_template_defaults
test_uses_scenario_cipher_contract
test_ignores_undeclared_plugin_credentials
test_accepts_public_ip_string_output
test_rejects_empty_node_output
test_rejects_empty_proxy_password
test_rejects_bundle_directory_symlink
test_node_refresh_keeps_pool_id_and_changes_revision
test_plugin_metadata_and_aliyun_binding
echo "PASS: redc-plugin-pojun-proxy post-apply"
