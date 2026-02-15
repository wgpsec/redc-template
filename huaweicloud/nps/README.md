# 华为云 NPS 场景

## 场景说明

本场景在华为云上部署 NPS（内网穿透服务器），用于红队渗透测试中的内网穿透需求。

## 配置说明

### 自动生成的资源

- **VPC 和子网**：自动创建独立的 VPC 网络环境
- **安全组**：自动创建并配置允许所有流量的安全组规则
- **EIP**：自动分配公网 IP
- **随机密码**：自动生成强随机密码用于 SSH 登录

### 实例配置

- **区域**：cn-north-4（北京四）
- **可用区**：cn-north-4a
- **镜像**：Ubuntu 18.04 server 64bit
- **规格**：1核1G（自动选择）
- **认证方式**：密码认证（自动生成）

## 使用方法

### 1. 配置华为云凭据

通过 redc-gui 的凭据管理页面配置，或编辑 `~/redc/config.yaml`：

```yaml
providers:
  huaweicloud:
    HUAWEICLOUD_ACCESS_KEY: "your_access_key"
    HUAWEICLOUD_SECRET_KEY: "your_secret_key"
```

### 2. 启动场景

```bash
redc run huaweicloud/nps
```

### 3. 获取连接信息

场景启动后，redc 会输出以下信息：

- **nps_ip**：NPS 服务器公网 IP
- **nps_address_link**：NPS Web 管理界面地址（http://IP:8080）
- **nps_username**：NPS 管理员用户名（redone）
- **nps_password**：NPS 管理员密码（1!2A3d4v5s6e）
- **ecs_password**：SSH 登录密码（自动生成）

### 4. SSH 连接

```bash
# 使用 redc SSH 功能
redc ssh <case_id>

# 或手动连接
ssh root@<nps_ip>
# 密码在 ecs_password 输出中
```

### 安全建议

- 场景创建后，建议立即修改 NPS 管理员密码
- 如需更严格的安全策略，可修改安全组规则限制访问源
- 使用完毕后及时销毁场景，避免产生不必要的费用

## 故障排查

### 实例创建失败

1. 检查华为云凭据是否正确
2. 确认账户余额充足
3. 检查区域配额是否足够

### NPS 服务未启动

1. SSH 登录实例检查日志：`journalctl -u nps`
2. 手动启动服务：`sudo nps start`
3. 检查配置文件：`/etc/nps/conf/nps.conf`

## 相关链接

- [NPS 官方文档](https://github.com/ehang-io/nps)
- [华为云 Terraform Provider 文档](https://registry.terraform.io/providers/huaweicloud/huaweicloud/latest/docs)
