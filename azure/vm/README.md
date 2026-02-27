# 场景使用

1. 使用前请 **一定** 按照注意事项里内容进行配置 (若空则无需配置)
2. 使用时命令如下

拉取
```
redc pull azure/vm
```

开启
```
redc run azure/vm
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

**Azure 凭据配置**

需要配置 Azure 服务凭据，详见 [redc 凭据管理](../../README_CN.md#azure-配置)

```yaml
# ~/redc/config.yaml
providers:
  azure:
    ARM_CLIENT_ID: "your-client-id"
    ARM_CLIENT_SECRET: "your-client-secret"
    ARM_SUBSCRIPTION_ID: "your-subscription-id"
    ARM_TENANT_ID: "your-tenant-id"
```

**区域说明**

默认使用 `West Europe`（西欧洲）区域

**配额问题**

Azure 创建虚拟机需要满足以下条件：

1. **区域配额**：目标区域需要有可用的 vCPU 配额
2. **SKU 可用性**：所选 VM 规格在该区域需要有可用容量

如遇到以下错误：
- `SkuNotAvailable`: VM 规格在当前区域不可用 → 更换 `vm_size` 或 `location`
- `quota exceeded`: vCPU 配额不足 → 在 Azure 门户申请增加配额，或更换区域

**默认配置**

| 参数 | 默认值 |
|------|--------|
| VM 规格 | Standard_D2a_v4 |
| 区域 | West Europe |
| 系统镜像 | Ubuntu 18.04 LTS |
| 用户名 | redcadmin |
| 密码 | 自动生成 |

**自定义参数**

可以通过 `terraform.tfvars` 覆盖默认配置：

```hcl
instance_password = "YourPassword123"
```
