# RedC 插件开发指南

本文档介绍如何编写一个 RedC 插件。插件可以在场景生命周期的关键节点（部署前/后、销毁前/后）执行自定义脚本，实现配置生成、文件上传、DNS 更新、Webhook 通知等扩展功能。

> 完整示例请参考 [redc-plugin-example](../plugins/redc-plugin-example/)，生产级参考请看 [redc-plugin-clash-config](../plugins/redc-plugin-clash-config/)、[redc-plugin-upload-r2](../plugins/redc-plugin-upload-r2/)、[redc-plugin-cloudflare-dns](../plugins/redc-plugin-cloudflare-dns/)。

## 目录结构

```
redc-plugin-your-name/
├── plugin.json              # 必须 — 插件清单文件
├── README.md                # 推荐 — 使用说明
├── hooks/                   # 可选 — 生命周期钩子脚本
│   ├── pre-plan.sh
│   ├── post-plan.sh
│   ├── pre-apply.sh
│   ├── post-apply.sh        # 最常用：部署完成后执行
│   ├── pre-destroy.sh
│   └── post-destroy.sh
└── templates/               # 可选 — 附带的 Terraform 模板
```

插件安装后存放在 `~/.redc/plugins/<plugin-name>/` 目录下。

## plugin.json 完整字段说明

`plugin.json` 是插件的唯一必须文件，定义了插件的元信息、能力声明和配置参数。

```jsonc
{
  // ── 基础信息 ──
  "name": "redc-plugin-your-name",       // 必填，插件名称，建议 redc-plugin- 前缀
  "version": "1.0.0",                    // 必填，语义化版本号
  "description": "插件功能的中文描述",      // 必填，中文描述
  "description_en": "English description", // 可选，英文描述
  "author": "your-name",                 // 可选，作者
  "homepage": "https://github.com/...",  // 可选，项目主页
  "category": "proxy",                   // 可选，分类（proxy/dns/storage/monitoring/example 等）
  "tags": ["clash", "proxy"],            // 可选，标签数组，用于搜索和分类
  "min_redc_version": "3.1.0",          // 可选，要求的最低 RedC 版本

  // ── 能力声明 ──
  "capabilities": {
    "hooks": {                           // 生命周期钩子，key 为钩子点，value 为脚本相对路径
      "post-apply": "hooks/post-apply.sh",
      "pre-destroy": "hooks/pre-destroy.sh"
    },
    "templates": ["templates/*.tf"],     // 可选，附带的 Terraform 模板（glob 模式）
    "userdata": ["userdata/*.sh"]        // 可选，附带的 Userdata 脚本（glob 模式）
  },

  // ── 配置参数（可选）──
  // 声明后 GUI 会自动渲染配置表单，用户可在「插件管理」页面填写
  "config_schema": {
    "notify_url": {
      "type": "string",                 // 类型：string / number / boolean
      "required": false,                // 是否必填
      "description": "Webhook 通知地址", // 参数说明
      "default": ""                     // 默认值
    },
    "enable_log": {
      "type": "boolean",
      "required": false,
      "description": "是否记录详细日志",
      "default": "true"
    }
  }
}
```

## 生命周期钩子

### 6 个钩子点

| 钩子点 | 触发时机 | 典型用途 |
|--------|---------|---------|
| `pre-plan` | `terraform plan` 之前 | 预检查、参数验证 |
| `post-plan` | `terraform plan` 之后 | 审查计划输出 |
| `pre-apply` | `terraform apply` 之前 | 准备外部资源 |
| `post-apply` | `terraform apply` 之后 | 生成配置、上传文件、更新 DNS、发通知 |
| `pre-destroy` | `terraform destroy` 之前 | 清理外部资源（DNS 记录、文件等） |
| `post-destroy` | `terraform destroy` 之后 | 发送销毁通知 |

### 执行规则

- 每个钩子脚本最长执行 **5 分钟**，超时自动终止
- 钩子失败**不会阻断**后续流程，错误会记录到日志并继续执行下一个插件的钩子
- 同一场景绑定多个插件时，按 `case.json` 中 `redc_plugins` 的声明顺序执行
- 脚本通过 `bash` 执行，工作目录为插件目录

### 环境变量

钩子脚本可通过以下环境变量获取场景信息和插件配置：

#### 场景信息

| 变量 | 说明 | 示例 |
|------|------|------|
| `REDC_HOOK_POINT` | 当前钩子点 | `post-apply` |
| `REDC_PLUGIN_NAME` | 插件名称 | `redc-plugin-clash-config` |
| `REDC_PLUGIN_DIR` | 插件目录绝对路径 | `/Users/xxx/.redc/plugins/redc-plugin-clash-config` |
| `REDC_CASE_NAME` | 场景名称 | `proxy-01` |
| `REDC_CASE_PATH` | 场景目录绝对路径 | `/Users/xxx/.redc/project/xxx/proxy-01` |
| `REDC_CASE_TEMPLATE` | 场景模板类型 | `aliyun/proxy` |
| `REDC_CASE_STATE` | 场景状态 | `running` |
| `REDC_OUTPUT_JSON` | Terraform 输出（JSON 格式） | `{"public_ip":{"value":["1.2.3.4"],...}}` |
| `REDC_CASE_VARS` | 场景参数（JSON 格式） | `{"region":"cn-beijing","node":"2"}` |

#### 插件配置

| 变量 | 说明 |
|------|------|
| `REDC_PLUGIN_CONFIG` | 完整配置（JSON 格式），如 `{"notify_url":"https://...","enable_log":true}` |
| `REDC_PLUGIN_CONFIG_<KEY>` | 单个配置值，key 转为大写并将 `-` 替换为 `_` |

**配置 key 转换规则：** `notify_url` → `REDC_PLUGIN_CONFIG_NOTIFY_URL`，`enable-log` → `REDC_PLUGIN_CONFIG_ENABLE_LOG`

### REDC_OUTPUT 协议

钩子脚本可以通过 stdout 输出特殊格式的行，将数据回传给 RedC：

```bash
echo "REDC_OUTPUT:clash_config_url=https://example.com/config.yaml"
echo "REDC_OUTPUT:node_count=3"
```

格式为 `REDC_OUTPUT:key=value`，每行一个键值对。这些输出会：
1. 持久化到场景目录下的 `plugin_outputs.json`
2. 合并到 GUI 的场景输出面板中展示
3. 可被后续插件和 AI Agent 读取

非 `REDC_OUTPUT:` 前缀的 stdout 内容会作为普通日志输出。

## 编写钩子脚本示例

一个典型的 `post-apply` 钩子：

```bash
#!/bin/bash
set -euo pipefail

echo "[my-plugin] post-apply hook triggered for ${REDC_CASE_NAME}"

# 1. 从 Terraform 输出获取 IP
IPS=$(echo "$REDC_OUTPUT_JSON" | jq -r '.public_ip.value[]' 2>/dev/null)
if [ -z "$IPS" ]; then
    echo "[my-plugin] no IPs found in outputs, skipping"
    exit 0
fi

# 2. 读取插件配置
PORT="${REDC_PLUGIN_CONFIG_PORT:-8388}"

# 3. 执行业务逻辑（示例：生成配置文件）
CONFIG_FILE="${REDC_CASE_PATH}/my-config.yaml"
echo "servers:" > "$CONFIG_FILE"
for ip in $IPS; do
    echo "  - address: $ip:$PORT" >> "$CONFIG_FILE"
done

# 4. 通过 REDC_OUTPUT 回传结果到 GUI
echo "REDC_OUTPUT:config_file=${CONFIG_FILE}"
echo "REDC_OUTPUT:server_count=$(echo "$IPS" | wc -l | tr -d ' ')"

# 5. 可选：Webhook 通知
if [ -n "${REDC_PLUGIN_CONFIG_NOTIFY_URL:-}" ]; then
    curl -s -X POST "$REDC_PLUGIN_CONFIG_NOTIFY_URL" \
        -H "Content-Type: application/json" \
        -d "{\"event\":\"deployed\",\"case\":\"${REDC_CASE_NAME}\",\"ips\":\"${IPS}\"}" \
        --max-time 10 || echo "[my-plugin] webhook failed (non-fatal)"
fi

echo "[my-plugin] done"
```

## 场景绑定插件

在模板的 `case.json` 中通过 `redc_plugins` 字段声明依赖的插件（逗号分隔）：

```json
{
  "name": "proxy",
  "description": "多节点代理场景",
  "redc_plugins": "redc-plugin-clash-config,redc-plugin-upload-r2",
  "template": "preset"
}
```

场景启动时，RedC 会按声明顺序执行这些插件的钩子。如果用户未安装声明的插件，GUI 会在启动前弹窗提醒。

## 安装与调试

### 安装方式

```bash
# 从 Git 仓库安装
redc plugin install https://github.com/your-org/redc-plugin-your-name

# 从本地路径安装（开发调试用）
redc plugin install /path/to/redc-plugin-your-name

# 从 ZIP URL 安装
redc plugin install https://example.com/redc-plugin-your-name.zip
```

GUI 中可在「插件管理」页面输入上述地址安装。

### 常用命令

```bash
redc plugin list                    # 列出已安装插件
redc plugin info <name>             # 查看插件详情
redc plugin enable <name>           # 启用插件
redc plugin disable <name>          # 禁用插件（在插件目录创建 .disabled 标记文件）
redc plugin update <name>           # 更新插件（Git: pull，ZIP: 重新下载）
redc plugin uninstall <name>        # 卸载插件
```

### 调试技巧

1. **本地安装开发：** 开发时用 `redc plugin install /local/path` 安装，修改代码后 `redc plugin update <name>` 更新
2. **查看日志：** 钩子脚本的 stdout/stderr 会输出到 RedC 日志和 GUI 控制台
3. **手动测试钩子：** 设置好环境变量后直接运行脚本
   ```bash
   REDC_CASE_NAME=test REDC_OUTPUT_JSON='{"public_ip":{"value":["1.2.3.4"]}}' \
   bash hooks/post-apply.sh
   ```
4. **检查输出：** 查看场景目录下的 `plugin_outputs.json` 确认 REDC_OUTPUT 是否正确写入

## 发布到插件市场

1. 将插件推送到公开的 Git 仓库
2. 向 [redc-template](https://github.com/wgpsec/redc-template) 提交 PR，将插件目录放到 `plugins/` 下
3. 合并后 GitHub Actions 会自动更新插件市场索引，用户即可在 GUI 的插件市场中发现和安装

## 现有插件参考

| 插件 | 功能 | 钩子 |
|------|------|------|
| [redc-plugin-clash-config](../plugins/redc-plugin-clash-config/) | 部署后生成 Clash 代理配置 | post-apply |
| [redc-plugin-upload-r2](../plugins/redc-plugin-upload-r2/) | 将生成的文件上传到 Cloudflare R2 | post-apply |
| [redc-plugin-cloudflare-dns](../plugins/redc-plugin-cloudflare-dns/) | 部署后更新 Cloudflare DNS 记录 | post-apply, pre-destroy |
| [redc-plugin-example](../plugins/redc-plugin-example/) | 示例插件（日志 + Webhook） | post-apply, pre-destroy |
