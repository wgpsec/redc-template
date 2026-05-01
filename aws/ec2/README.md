# AWS EC2

## 场景说明

这个场景会在 AWS ap-east-1（香港）区域部署一台通用 EC2 主机，默认使用 ARM64 的 `t4g.small` 和 Debian 镜像，并预装常见运维工具。适合快速拿到一台带公网 IP、可直接 SSH 登录的基础节点。

## 前置条件

- AWS 账号已开通 `ap-east-1`（香港）区域。
- 本地 redc 已配置可用的 AWS 凭据。
- 如果你准备改 `instance_type`，需要确认它和 `ami` 的架构一致；当前默认组合是 ARM64。

## 快速使用

拉取场景：

```bash
redc pull aws/ec2
```

使用默认参数启动：

```bash
redc run aws/ec2
```

按需覆盖实例类型或磁盘大小：

```bash
redc run aws/ec2 -e instance_type=t4g.small -e volume_size=30
```

查看运行状态：

```bash
redc status [uuid]
```

停止场景：

```bash
redc stop [uuid]
```

## 参数说明

| 参数 | 默认值 | 说明 |
| --- | --- | --- |
| `region` | `ap-east-1` | AWS 区域，默认香港区域。 |
| `instance_type` | `t4g.small` | 实例规格，默认 ARM64 机型。 |
| `ami` | `ami-01c9cc5554738042c` | 默认 Debian ARM64 镜像；如果改成 x86 实例类型，需要同步替换成兼容镜像。 |
| `volume_size` | `18` | 根磁盘大小，单位 GB。 |

## 输出说明

- `public_ip`：实例公网 IP。
- `public_dns`：实例公网 DNS。
- `ssh_private_key_path`：本地生成的 SSH 私钥文件路径。
- `ssh_user`：默认 SSH 用户名，当前为 `admin`。
- `ssh_command`：可直接复制使用的 SSH 连接命令。

## 注意事项

- 默认安全组会放开全部入站和出站流量，部署后请按你的使用场景自行收紧。
- 用户数据里会写入一条 iptables 规则，用于阻断对 `169.254.169.254` 元数据地址的访问。
- 如果启动失败，常见原因是区域未开通、该区域库存不足，或 `instance_type` 与 `ami` 架构不匹配。

## 附录

如需确认香港区域是否已开通，可参考下图：

![](../../img/redc-2.png)

![](../../img/redc-3.png)
