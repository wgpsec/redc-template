# redc-plugin-cloudflare-dns

场景部署后自动更新 Cloudflare DNS A 记录，销毁时可自动清理。

## 功能

- **post-apply**: 从 Terraform outputs 获取实例 IP，创建/更新 Cloudflare DNS A 记录
- **pre-destroy**: 销毁场景前自动删除 DNS 记录（可配置关闭）

## 依赖

- `jq` — 解析 JSON
- `curl` — 调用 Cloudflare API

## 安装

```bash
redc plugin install https://redc.wgpsec.org/plugins/redc-plugin-cloudflare-dns
```

## 配置

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `cf_email` | string | ✅ | Cloudflare 账户邮箱 |
| `cf_api_key` | string | ✅ | Cloudflare Global API Key |
| `domain` | string | - | 域名，不填从 tfvars `domain` 读取 |
| `record_name` | string | - | DNS 记录名，不填使用 `ns1.<zone>` |
| `cleanup_on_destroy` | boolean | - | 销毁时删除记录，默认 `true` |

### 配置示例

```json
{
  "cf_email": "your@email.com",
  "cf_api_key": "your-global-api-key",
  "domain": "ns1.example.com",
  "cleanup_on_destroy": true
}
```

## 凭证读取优先级

1. 插件配置 (`cf_email` / `cf_api_key`)
2. 环境变量 (`CF_EMAIL` / `CF_API_KEY`)
3. 环境变量 (`CF_API_EMAIL` / `CF_KEY`)

## 对应内置模块

此插件是内置模块 `chang_dns` 的独立插件版本，增加了销毁时自动清理 DNS 记录的功能。
