# UCloud UHost 场景

使用 Terraform 在 UCloud 创建 UHost 实例。

## 使用方法

### 1. 拉取场景

```bash
redc pull ucloud/uhost
cd ucloud/uhost
```

### 2. 配置凭据

在 `config.yaml` 中配置 UCloud 凭据：

```yaml
providers:
  ucloud:
    public_key: "your_public_key"
    private_key: "your_private_key"
    project_id: "Default"
    region: "cn-bj2"
```

或者通过环境变量：

```bash
export UCLOUD_PUBLIC_KEY="your_public_key"
export UCLOUD_PRIVATE_KEY="your_private_key"
export UCLOUD_PROJECT_ID="Default"
```

### 3. 自定义配置（可选）

编辑 `terraform.tfvars` 修改默认配置：

```hcl
instance_name        = "my-uhost"
instance_type        = "n-standard-2"
availability_zone    = "cn-bj2-05"
image_id            = "uimage/uhost/CentOS_7.6_x64_20G_alibaba"
password             = "YourPassword123"
```

### 4. 运行场景

```bash
redc run ucloud/uhost
```

### 5. 查看状态

```bash
redc status
```

### 6. 停止并销毁

```bash
redc stop
```

## 变量说明

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `region` | cn-bj2 | 区域 |
| `availability_zone` | cn-bj2-05 | 可用区 |
| `project_id` | Default | 项目 ID |
| `instance_name` | redc-uhost | 实例名称 |
| `instance_type` | n-standard-1 | 实例规格 |
| `image_id` | uimage/uhost/CentOS_7.6_x64_20G_alibaba | 镜像 ID |
| `password` | UCloud2024 | 实例密码 |

## 输出说明

| 输出 | 说明 |
|------|------|
| `instance_id` | 实例 ID |
| `instance_name` | 实例名称 |
| `private_ip` | 内网 IP |
| `public_ip` | 公网 IP |

## 常用可用区

- `cn-bj2-05` - 北京二区 05
- `cn-sh2-03` - 上海二区 03
- `cn-gd-02` - 广州区 02

## 注意事项

1. 确保 UCloud 账户余额充足
2. 默认 project_id 为 "Default"
3. 默认使用按量付费，停止后不会产生费用
