# redc-plugin-clash-config

场景部署后自动生成 Clash (Shadowsocks) 代理配置文件。

## 功能

从 Terraform outputs 中提取实例 IP，结合 `terraform.tfvars` 中的 `port` 和 `password` 参数，自动生成 Clash 配置文件（load-balance 模式）。

## 依赖

- `jq` — 用于解析 Terraform 输出 JSON

## 安装

```bash
redc plugin install https://redc.wgpsec.org/plugins/redc-plugin-clash-config
```

## 使用

1. 模板的 `terraform.tfvars` 中需包含 `port` 和 `password` 变量
2. 部署场景后，插件自动在场景目录下生成 Clash 配置文件

## 配置

| 参数 | 类型 | 说明 |
|------|------|------|
| `port` | string | SS 端口，不填则从 tfvars 读取 |
| `password` | string | SS 密码，不填则从 tfvars 读取 |
| `filename` | string | 输出文件名，默认 `config.yaml` |

## 对应内置模块

此插件是内置模块 `gen_clash_config` 的独立插件版本。
