# AWS HackMD/Docker

## 场景说明

这个场景会在 AWS ap-east-1（香港）区域部署一台 ARM64 EC2 主机，自动安装 Docker，并通过运行时下载的 `docker-compose.yml` 启动一个 HackMD 协作文档服务。适合快速拉起一个临时的在线协作文档节点。

## 前置条件

- AWS 账号已开通 `ap-east-1`（香港）区域。
- 本地 redc 已配置可用的 AWS 凭据。
- 当前默认实例类型是 ARM64 的 `t4g.medium`，如果你覆盖 `instance_type`，需要同步确认 `ami` 架构兼容。
- 场景初始化依赖外部网络下载 `f8x` 和 `docker-compose.yml`，如果出口受限，服务启动可能失败。

## 快速使用

```bash
redc pull aws/md
redc run aws/md
redc status [uuid]
redc stop [uuid]
```

如需覆盖实例规格或根盘大小，可以这样启动：

```bash
redc run aws/md -e instance_type=t4g.medium -e volume_size=30
```

## 参数说明

| 参数 | 默认值 | 说明 |
| --- | --- | --- |
| `region` | `ap-east-1` | AWS 区域，默认香港区域。 |
| `instance_type` | `t4g.medium` | EC2 实例规格，当前是 ARM64 机型。 |
| `ami` | `ami-01c9cc5554738042c` | 默认 Debian ARM64 镜像；如果切换到其他架构实例，需要同步替换成兼容镜像。 |
| `volume_size` | `18` | 根磁盘大小，单位 GB。 |

## 输出说明

- `public_ip`：实例公网 IP。
- `public_dns`：实例公网 DNS。
- `md_address_link`：HackMD 访问地址，默认监听 `3000` 端口。
- `ssh_private_key_path`：本地生成的 SSH 私钥路径。
- `ssh_user`：默认 SSH 用户名，当前为 `admin`。
- `ssh_command`：可直接复制使用的 SSH 连接命令。

## 注意事项

- 模板会在本地生成 ED25519 私钥文件，用于实例 SSH 登录。
- 默认安全组会放开全部入站和出站流量；HackMD 默认通过 `3000` 端口暴露。
- 用户数据会先下载 `f8x` 安装 Docker，再在 `tmux` 会话中执行 `docker compose up -d`，因此实例创建成功后仍可能需要等待几分钟服务才会可用。
- 预置的 `docker-compose.yml` 下载地址写在模板里，当前为：
	- https://github.com/No-Github/Archive/releases/download/1.0.8/docker-compose.yml
- 如果启动失败，常见原因是区域未开通、API 网络超时、实例规格与 AMI 架构不匹配，或 `f8x` 自动安装 Docker 失败。

## 附录

如需确认香港区域是否已开通，可参考下图：

![](../../img/redc-2.png)

![](../../img/redc-3.png)
