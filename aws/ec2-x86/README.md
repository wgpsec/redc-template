# AWS EC2 x86 通用场景

ap-east-1 区域，t3.medium 实例（x86_64 架构，2C4G），预装基础运维工具。

适用于需要 x86 兼容性的部署场景，如 VulHub 漏洞环境、仅提供 x86 Docker 镜像的项目。

## 配置

| 参数 | 值 |
|------|------|
| 区域 | ap-east-1 (香港) |
| 实例类型 | t3.medium |
| 架构 | x86_64 |
| 系统盘 | 20GB gp3 |
| AMI | Debian (x86_64) |

## 常见问题

1. 创建实例后 SSH 连不上：实例刚启动需要 1-2 分钟初始化
2. aws 该区域售罄或下架 instance_type 的配置机型
3. AMI 架构与 instance_type 不匹配
