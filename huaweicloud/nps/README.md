# 华为云 NPS

## 场景说明

这个场景会在华为云 `cn-north-4`（北京四）区域部署一台 Ubuntu 18.04 x86_64 主机，自动安装 NPS 并通过公网 EIP 暴露 Web 管理界面。它会额外创建独立 VPC、子网、安全组和 EIP，适合需要快速拉起一个 NPS 服务端进行验证或临时联调的场景。

## 前置条件

- 需要准备可用的华为云凭据：`huaweicloud_access_key` 和 `huaweicloud_secret_key`。
- 需要提供 `github_proxy`，模板会通过 `${github_proxy}/ehang-io/nps/...` 下载 NPS 服务端安装包。
- 需要提供 `base64_command`，其内容会被 base64 解码后写入 `/etc/nps/conf/nps.conf` 作为实际配置文件。
- `instance_password` 可留空自动生成，也可以在启动时显式传入固定密码。

## 快速使用

拉取场景：

```bash
redc pull huaweicloud/nps
```

准备好 NPS 配置文件后，将其编码成 base64，再启动场景：

```bash
redc run huaweicloud/nps \
  -e huaweicloud_access_key=YOUR_ACCESS_KEY \
  -e huaweicloud_secret_key=YOUR_SECRET_KEY \
  -e github_proxy=https://YOUR_GITHUB_PROXY \
  -e base64_command=BASE64_ENCODED_NPS_CONF
```

如果你希望固定实例登录密码，也可以一并覆盖：

```bash
redc run huaweicloud/nps \
  -e huaweicloud_access_key=YOUR_ACCESS_KEY \
  -e huaweicloud_secret_key=YOUR_SECRET_KEY \
  -e github_proxy=https://YOUR_GITHUB_PROXY \
  -e base64_command=BASE64_ENCODED_NPS_CONF \
  -e instance_password='YourPassword123!'
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
| `huaweicloud_access_key` | 必填 | 华为云 Access Key。 |
| `huaweicloud_secret_key` | 必填 | 华为云 Secret Key。 |
| `base64_command` | 必填 | NPS 配置文件的 base64 内容，启动时会写入 `/etc/nps/conf/nps.conf`。 |
| `github_proxy` | 必填 | NPS 安装包下载前缀，例如可访问 GitHub Release 的代理地址。 |
| `instance_password` | 自动生成 | 实例 root 登录密码；留空时模板会自动生成随机密码。 |

## 输出说明

- `nps_ip`：NPS 服务端公网 IP。
- `nps_address_link`：模板输出的默认 Web 管理地址提示值，按仓库示例配置时通常是 `http://公网IP:8080`；如果你传入了自定义 `nps.conf`，则以其中的 `web_port` / `web_open_ssl` 等配置为准。
- `nps_username`：模板输出的默认 Web 用户名提示值，按仓库示例配置时为 `redone`；如果你自定义了 `nps.conf`，则以其中的 `web_username` 为准。
- `nps_password`：模板输出的默认 Web 密码提示值，按仓库示例配置时为 `1!2A3d4v5s6e`；如果你自定义了 `nps.conf`，则以其中的 `web_password` 为准。
- `ecs_ip` / `public_ip`：实例公网 IP。
- `ecs_password` / `ssh_password`：实例 root 登录密码。
- `ssh_user`：默认 SSH 用户名，当前为 `root`。
- `ssh_command`：可直接复制使用的 SSH 命令。

## 注意事项

- 模板里的地域固定为 `cn-north-4`，可用区固定为 `cn-north-4a`；实例规格会从 1 核 1G 的 flavor 列表里自动选择。
- 安全组会放开全部 IPv4 入站和出站流量，如需长期使用，请在部署后尽快收紧访问范围。
- 用户数据会先安装 tmux、wget、unzip 等基础工具，再下载并安装 NPS，随后把 `base64_command` 解码写入 `/etc/nps/conf/nps.conf` 并启动服务。
- 仓库里的示例 `nps.conf` 使用 `redone / 1!2A3d4v5s6e / 8080` 作为 Web 管理端默认值；如果你通过 `base64_command` 传入了自定义配置，实际运行值会以你的 `nps.conf` 为准。
- 如果启动失败，常见原因是华为云凭据错误、账户余额或配额不足、`github_proxy` 无法访问，或 `base64_command` 不是有效的 NPS 配置内容。
