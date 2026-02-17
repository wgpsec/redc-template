# 阿里云 ECS 实例模板

这是一个用于创建阿里云 ECS 实例的 Terraform 模板。

## 功能特性

- 自动创建 VPC 和交换机
- 配置安全组规则（SSH、HTTP、HTTPS）
- 支持自定义实例规格和系统盘大小
- 支持用户数据脚本（user_data）
- 自动分配公网 IP

## 使用前提

1. 配置阿里云访问凭证：
   - 设置环境变量 `ALICLOUD_ACCESS_KEY` 和 `ALICLOUD_SECRET_KEY`
   - 或在 `~/.aliyun/config.json` 中配置

2. 确保账户有足够的权限创建 ECS、VPC、安全组等资源

## 配置参数

### 必需参数

- `region`: 阿里云区域（如 `cn-hangzhou`、`cn-beijing`）
- `instance_type`: 实例规格（如 `ecs.t6-c1m1.large`）
- `instance_password`: 实例密码（如果不提供，系统会自动生成）

### 可选参数

- `instance_name`: 实例名称（默认：`alicloud-ecs-instance`）
- `system_disk_size`: 系统盘大小，单位 GB（默认：40）
- `system_disk_category`: 系统盘类型（默认：`cloud_efficiency`，高效云盘）
  - `cloud_efficiency`: 高效云盘（推荐，所有区域和实例规格都支持）
  - `cloud_ssd`: SSD 云盘（高性能，大部分区域支持）
  - `cloud_essd`: ESSD 云盘（超高性能，部分区域/实例规格支持）
  - `cloud_essd_entry`: 入门级 ESSD（部分区域/实例规格支持）
- `userdata`: 用户数据脚本
- `internet_max_bandwidth_out`: 公网带宽，单位 Mbps（默认：1）

## 输出信息

- `instance_id`: 实例 ID
- `instance_name`: 实例名称
- `public_ip`: 公网 IP 地址
- `private_ip`: 私网 IP 地址
- `region`: 区域
- `instance_type`: 实例规格
- `ssh_command`: SSH 连接命令
- `available_zones`: 支持该实例规格的所有可用区列表
- `selected_zone`: 当前使用的可用区

## 示例

创建一个基本的 ECS 实例：

```hcl
region        = "cn-hangzhou"
instance_type = "ecs.t6-c1m1.large"
instance_name = "my-ecs-instance"
```

## 注意事项

1. 实例密码要求：8-30个字符，必须包含大小写字母、数字
2. 系统会自动选择支持指定实例规格的可用区
3. 默认使用 Ubuntu 20.04 镜像
4. 公网带宽按流量计费

### 处理可用区资源售罄问题

如果部署时遇到以下错误：
```
Zone.NotOnSale: The resource in the specified zone is no longer available for sale.
```

这说明当前选择的可用区中该实例规格已售罄。解决方法：

1. 查看部署输出的 `available_zones`，了解有哪些可用区支持该实例规格
2. 编辑部署目录中的 `data.tf` 文件，修改 `locals` 块中的 `zone_index` 值：
   ```hcl
   locals {
     zone_index = 1  # 改为 1 尝试第二个可用区，改为 2 尝试第三个，以此类推
   }
   ```
3. 重新运行 `terraform apply`
4. 或者选择其他实例规格

## 资源清单

该模板会创建以下资源：

- 1 个 VPC
- 1 个交换机（VSwitch）
- 1 个安全组
- 4 条安全组规则（SSH、HTTP、HTTPS、出站）
- 1 个 ECS 实例（带公网 IP）
