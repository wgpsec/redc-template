# 火山引擎 ECS 模板

## 简介

这是一个用于在火山引擎上创建 ECS 实例的基础模板。

## 功能特性

- 自动创建 VPC 和子网
- 配置安全组（开放 SSH、HTTP、HTTPS 端口）
- 分配公网 IP
- 支持自定义用户数据脚本
- 支持自定义实例密码

## 使用方法

### 必需参数

- `region`: 火山引擎区域（如 `cn-beijing`）
- `instance_type`: 实例规格（如 `ecs.g3i.large`）

### 可选参数

- `instance_name`: 实例名称（默认: `volcengine-ecs`）
- `instance_password`: 实例密码（如果不设置，需要使用密钥登录）
- `system_disk_size`: 系统盘大小，单位 GB（默认: `40`）
- `internet_max_bandwidth_out`: 公网带宽，单位 Mbps（默认: `1`）
- `userdata`: 用户数据脚本（可选）

## 输出

- `instance_id`: 实例 ID
- `instance_name`: 实例名称
- `public_ip`: 公网 IP 地址
- `private_ip`: 私网 IP 地址
- `region`: 区域
- `instance_type`: 实例规格

## 注意事项

1. 确保你的火山引擎账号有足够的配额
2. 实例密码必须符合火山引擎的密码策略
3. 系统盘类型固定为 `ESSD_PL0`（标准云盘）
4. 默认使用 veLinux 1.0 CentOS 兼容版镜像

## 成本估算

- ECS 实例费用根据实例规格和使用时长计费
- 公网带宽按实际使用流量或固定带宽计费
- 系统盘按容量和类型计费

## 示例

```hcl
region                      = "cn-beijing"
instance_type               = "ecs.g3i.large"
instance_name               = "my-server"
instance_password           = "MyPassword123!"
system_disk_size            = 40
internet_max_bandwidth_out  = 5
userdata                    = <<-EOT
#!/bin/bash
yum update -y
yum install -y nginx
systemctl start nginx
systemctl enable nginx
EOT
```
