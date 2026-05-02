# AWS Docker

## 场景说明

这个场景会在 AWS ap-east-1（香港）区域部署一台 x86_64 EC2 主机，默认使用 `t3.medium`、Debian x86_64 镜像和 18GB 根磁盘。实例启动后会通过 `f8x -docker` 自动安装 Docker，并在名为 `docker` 的 tmux 会话中后台执行，适合作为一个开箱即用的 Docker 基础节点。

## 前置条件

- AWS 账号已开通 `ap-east-1`（香港）区域。
- 本地 redc 已配置可用的 AWS 凭据。
- 如果你准备改 `instance_type` 或 `ami`，需要确认二者架构一致；当前默认组合是 x86_64。
- 首次启动需要访问系统软件源和 `https://f8x.wgpsec.org/f8x` 下载依赖。

## 快速使用

拉取场景：

```bash
redc pull aws/docker
```

使用默认参数启动：

```bash
redc run aws/docker
```

按需覆盖实例规格或根磁盘大小：

```bash
redc run aws/docker -e instance_type=t3.large -e volume_size=30
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
| `instance_type` | `t3.medium` | EC2 实例规格，默认 x86_64 机型。 |
| `ami` | `ami-01c6db7097043551d` | 默认 Debian x86_64 镜像；如果改成 ARM 实例类型，需要同步换成兼容镜像。 |
| `volume_size` | `18` | 根磁盘大小，单位 GB。 |

## 输出说明

- `public_ip`：实例公网 IP。
- `public_dns`：实例公网 DNS。
- `ssh_private_key_path`：本地生成的 ED25519 SSH 私钥文件路径。
- `ssh_user`：默认 SSH 用户名，当前为 `admin`。
- `ssh_command`：可直接复制使用的 SSH 命令。

## 注意事项

- 默认安全组会放开全部入站和出站流量，部署后请按你的使用场景自行收紧。
- 用户数据会在 root 创建的 tmux 会话 `docker` 里执行 `f8x -docker`；如果想看安装进度，可以 SSH 登录后执行 `sudo tmux attach -t docker`。
- 这个场景会在本地生成一个临时 ED25519 私钥文件用于 SSH 登录。
- 如果启动失败，常见原因是区域未开通、该区域库存不足、`instance_type` 与 `ami` 架构不匹配，或 `f8x`/软件源下载失败。

## 附录

如需确认香港区域是否已开通，可参考下图：

![](../../img/redc-2.png)

![](../../img/redc-3.png)
