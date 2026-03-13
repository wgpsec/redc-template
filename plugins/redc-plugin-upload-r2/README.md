# redc-plugin-upload-r2

场景部署后将生成的配置文件上传到 Cloudflare R2 存储桶。

## 依赖

- `rclone` — 需要提前配置好名为 `r2` 的 remote

```bash
rclone config
# Type: s3
# Provider: Cloudflare
# ...
```

## 安装

```bash
redc plugin install https://redc.wgpsec.org/plugins/redc-plugin-upload-r2
```

## 配置

| 参数 | 类型 | 说明 |
|------|------|------|
| `bucket_name` | string | R2 桶名，不填从 tfvars `buckets_name` 读取，兜底 `test` |
| `bucket_path` | string | 桶内路径，不填从 tfvars `buckets_path` 读取 |
| `filename` | string | 要上传的文件名，不填从 tfvars `filename` 读取，兜底 `default-config.yaml` |

## 搭配使用

通常与 `redc-plugin-clash-config` 搭配：先生成配置文件，再上传到 R2。

## 对应内置模块

此插件是内置模块 `upload_r2` 的独立插件版本。
