# AWS EC2 x86

## 场景说明

这个场景会在 AWS ap-east-1（香港）区域部署一台 x86_64 EC2 主机，默认使用 `t3.medium` 和 Debian x86 镜像。适合运行只提供 x86 镜像的 Docker 环境、VulHub 类实验环境或其他不兼容 ARM 的软件。

## 前置条件

- AWS 账号已开通 `ap-east-1`（香港）区域。
- 本地 redc 已配置可用的 AWS 凭据。
- 当前默认实例类型是 x86_64 的 `t3.medium`，如果你覆盖 `instance_type`，需要同步确认 `ami` 架构兼容。

## 快速使用

```bash
redc pull aws/ec2-x86
redc run aws/ec2-x86
redc status [uuid]
redc stop [uuid]
```

如需覆盖实例规格或根盘大小，可以这样启动：

```bash
redc run aws/ec2-x86 -e instance_type=t3.medium -e volume_size=30
```

## 参数说明

| 参数 | 默认值 | 说明 |
| --- | --- | --- |
| `region` | `ap-east-1` | AWS 区域，默认香港区域。 |
| `instance_type` | `t3.medium` | EC2 实例规格，当前是 x86_64 机型。 |
| `ami` | `ami-01c6db7097043551d` | 默认 Debian x86_64 镜像；如果切换到 ARM 实例，需要同步替换成兼容镜像。 |
| `volume_size` | `20` | 根磁盘大小，单位 GB。 |

## 输出说明

- `public_ip`：实例公网 IP。
- `public_dns`：实例公网 DNS。
- `ssh_private_key_path`：本地生成的 SSH 私钥路径。
- `ssh_user`：默认 SSH 用户名，当前为 `admin`。
- `ssh_command`：可直接复制使用的 SSH 连接命令。

## 注意事项

- 模板会在本地生成 ED25519 私钥文件，用于实例 SSH 登录。
- 用户数据会写入一条 iptables 规则，阻断到 `169.254.169.254` 元数据地址的访问；依赖实例元数据的工具可能因此受影响。
- 默认安全组会放开全部入站和出站流量，部署后请按需收紧。
- 如果启动失败，常见原因是区域未开通、API 网络超时，或实例规格与 AMI 架构不匹配。

## 附录

这个场景更适合需要 x86 兼容性的部署任务，例如仅提供 x86 Docker 镜像的项目或 VulHub 类实验环境。
