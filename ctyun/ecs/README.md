# 天翼云 ECS 场景

使用 Terraform 在天翼云创建 ECS 实例。

## 使用方法

### 1. 拉取场景

```bash
redc pull ctyun/ecs
cd ctyun/ecs
```

### 2. 配置凭据

在 `config.yaml` 中配置天翼云凭据：

```yaml
providers:
  ctyun:
    access_key: "your_access_key"
    secret_key: "your_secret_key"
    region: "cn-gd"
```

或者通过环境变量：

```bash
export CTYUN_ACCESS_KEY="your_access_key"
export CTYUN_SECRET_KEY="your_secret_key"
```

### 3. 自定义配置（可选）

编辑 `terraform.tfvars` 修改默认配置：

```hcl
instance_name  = "my-ecs"
instance_type = "s3.medium.2"
region        = "cn-gd"
```

### 4. 运行场景

```bash
redc run ctyun/ecs
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
| `region` | cn-gd | 区域，如 cn-gd, cn-sh |
| `instance_name` | redc-ecs | 实例名称 |
| `instance_type` | s3.medium.1 | 实例规格 |
| `image_id` | (空) | 镜像 ID，留空则使用默认 |
| `password` | (自动生成) | 实例密码 |

## 输出说明

| 输出 | 说明 |
|------|------|
| `instance_id` | 实例 ID |
| `instance_name` | 实例名称 |
| `private_ip` | 内网 IP |
| `ssh_user` | SSH 用户名 |
| `ssh_password` | SSH 密码 |

## 常用区域

- `cn-gd` - 广东
- `cn-sh` - 上海
- `cn-bj` - 北京

## 注意事项

1. 确保天翼云账户余额充足
2. 实例规格和区域可根据需要调整
