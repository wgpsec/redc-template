# 场景使用

1. 使用前请 **一定** 按照注意事项里内容进行配置 (若空则无需配置)
2. 使用时命令如下

拉取
```
redc pull gcp/compute_instance
```

开启
```
redc run gcp/compute_instance
```

查询
```
redc status [uuid]
```

关闭
```
redc stop [uuid]
```

# 注意事项

**GCP 凭据配置**

需要配置 GCP 服务账号 JSON 凭据文件路径，详见 [redc 凭据管理](../../README_CN.md#gcp-配置)

```yaml
# ~/redc/config.yaml
providers:
  google:
    GOOGLE_APPLICATION_CREDENTIALS: "/path/to/your-service-account.json"
    project: "your-project-id"
    region: "us-central1"
```

**区域配置**

默认使用 us-central1 (爱荷华) 区域

若启动场景报错，可能原因
1. 与 GCP API 网络连接超时
2. GCP 项目未启用 Compute Engine API
3. 服务账号权限不足
4. 该区域无可用资源
