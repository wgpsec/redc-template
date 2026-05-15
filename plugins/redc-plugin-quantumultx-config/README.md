# redc-plugin-quantumultx-config

场景部署后自动生成 QuantumultX 订阅文件（Base64 编码的 ss:// URI 列表）。

## 功能

从 Terraform outputs 中提取实例 IP，结合 `terraform.tfvars` 中的 `port` 和 `password` 参数，生成符合 SIP002 标准的 `ss://` URI 列表，整体 Base64 编码后输出为订阅文件。

生成两个文件：
- `quantumultx.txt` — Base64 编码的订阅文件（可直接托管为订阅链接）
- `quantumultx.plain.txt` — 明文 ss:// URI 列表（方便查看和手动复制）

## 依赖

- `jq` — 用于解析 Terraform 输出 JSON
- `base64` — 用于编码（系统自带）

## 安装

```bash
redc plugin install https://redc.wgpsec.org/plugins/redc-plugin-quantumultx-config
```

## 使用

1. 模板的 `terraform.tfvars` 中需包含 `port` 和 `password` 变量
2. 部署场景后，插件自动在场景目录下生成订阅文件

## 配置

| 参数 | 类型 | 说明 |
|------|------|------|
| `port` | string | SS 端口，不填则从 tfvars 读取 |
| `password` | string | SS 密码，不填则从 tfvars 读取 |
| `filename` | string | 输出文件名，默认 `quantumultx.txt` |
| `tag_prefix` | string | 节点名称前缀，默认 `proxy` |

## 生成格式示例

**明文 (quantumultx.plain.txt)**：
```
ss://Y2hhY2hhMjAtaWV0Zi1wb2x5MTMwNTpPOUUzYjEvT2R4Q3JMa1RtV3lUTDd3PT0=@3.4.5.6:60001#proxy-1
ss://Y2hhY2hhMjAtaWV0Zi1wb2x5MTMwNTpPOUUzYjEvT2R4Q3JMa1RtV3lUTDd3PT0=@7.8.9.10:60001#proxy-2
```

**订阅文件 (quantumultx.txt)**：上述内容整体 Base64 编码

## QuantumultX 导入方式

1. **订阅链接**：将 `quantumultx.txt` 文件内容托管到 HTTP 服务器，在 QuantumultX 设置 → 节点 → 引用(订阅) 中添加链接
2. **手动添加**：复制 `quantumultx.plain.txt` 中的 `ss://` 链接，在 QuantumultX 中逐个添加
3. **配合 redc upload_r2**：上传到 R2 存储后直接获得订阅 URL
