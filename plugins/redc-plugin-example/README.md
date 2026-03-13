# redc-plugin-example

RedC 示例插件，展示插件开发的基本结构和功能。

## 功能

- **post-apply 钩子**：场景部署完成后记录日志，可选发送 Webhook 通知
- **pre-destroy 钩子**：场景销毁前记录日志，可选发送 Webhook 通知

## 安装

```bash
# CLI 安装
redc plugin install https://redc.wgpsec.org/plugins/redc-plugin-example

# 或从本地路径安装
redc plugin install /path/to/redc-plugin-example
```

GUI 中也可在「插件管理」页面输入上述地址安装。

## 配置

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `notify_url` | string | 否 | 部署/销毁事件的 Webhook 通知地址 |
| `enable_log` | boolean | 否 | 是否记录详细日志到插件目录（默认 true） |

### 配置示例

```json
{
  "notify_url": "https://your-webhook.example.com/redc",
  "enable_log": true
}
```

## 开发你自己的插件

以此插件为模板，创建你自己的 RedC 插件：

### 1. 创建目录结构

```
redc-plugin-your-name/
├── plugin.json          # 必须 — 插件清单
├── README.md            # 推荐 — 使用说明
├── hooks/               # 可选 — 生命周期钩子脚本
│   ├── pre-plan.sh
│   ├── post-plan.sh
│   ├── pre-apply.sh
│   ├── post-apply.sh
│   ├── pre-destroy.sh
│   └── post-destroy.sh
└── templates/           # 可选 — Terraform 模板
```

### 2. 编写 plugin.json

参考本插件的 `plugin.json`，关键字段：
- `name`：插件名称，建议 `redc-plugin-` 前缀
- `capabilities.hooks`：声明钩子脚本路径
- `config_schema`：声明配置参数，GUI 会自动渲染配置表单

### 3. 编写钩子脚本

钩子脚本通过环境变量获取场景信息和插件配置：

```bash
#!/bin/bash
# 场景信息
echo $REDC_CASE_NAME        # 场景名称
echo $REDC_CASE_TEMPLATE    # 模板类型
echo $REDC_OUTPUT_JSON      # Terraform 输出（JSON）

# 插件配置
echo $REDC_PLUGIN_CONFIG    # 完整配置（JSON）
echo $REDC_PLUGIN_CONFIG_MY_KEY  # 单个配置值（大写 + 下划线）
```

### 4. 发布

将插件推送到 Git 仓库，用户即可通过 URL 安装：

```bash
redc plugin install https://github.com/your-org/redc-plugin-your-name
```

## License

MIT
