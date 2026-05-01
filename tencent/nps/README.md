# NPS 内网穿透场景

## 场景说明

该场景会在腾讯云 ap-beijing 区域部署一台预置 nps server 的 x86_64 主机，适合快速搭建内网穿透、端口转发和基础代理入口。

部署完成后，你会得到 NPS 后台访问地址、默认后台账号密码、实例公网 IP 以及 SSH 登录命令；默认情况下模板会使用仓库内置的 [nps.conf](nps.conf)，如果需要自定义启动配置，也可以在启动时注入 base64 编码后的配置内容。

## 前置条件

- 需要可用的腾讯云凭据，并确保账号具有创建 CVM、安全组等资源的权限。
- 该模板固定使用 ap-beijing 区域的 S6 2C2G 机型族，需确认区域容量和账户余额可用。
- 如果不通过 redc 管理云凭据，需自行在 `terraform.tfvars` 中填写 `tencentcloud_secret_id` 和 `tencentcloud_secret_key`。
- 如果要加载自定义 `nps.conf`，需要先准备配置文件并自行转成 base64 文本。

## 快速使用

```bash
redc pull tencent/nps
redc run tencent/nps
redc status [uuid]
redc stop [uuid]
```

如果要在启动时加载自定义 `nps.conf`，可通过通用变量入口传入 `base64_command`，例如：

```bash
redc run tencent/nps -e base64_command="$(base64 < nps.conf | tr -d '\n')"
```

## 参数说明

| 参数名 | 是否必填 | 默认值 | 示例 | 行为影响 |
|--------|----------|--------|------|----------|
| `instance_name` | 否 | `nps` | `nps-prod` | 控制实例名称，便于在腾讯云控制台中区分不同部署。 |
| `instance_password` | 否 | 自动生成 | `StrongPass123!` | 控制实例 SSH 登录密码；留空时自动生成，并通过输出返回。 |
| `base64_command` | 否 | 模板内置 `nps.conf` | `$(base64 < nps.conf | tr -d '\n')` | 用于启动时覆盖默认 `nps.conf`，决定 NPS 的桥接端口、Web 后台配置等行为。 |
| `github_proxy` | 否 | `https://ghfast.top/github.com` | `https://ghproxy.link/github.com` | 控制 nps 安装包下载加速地址，影响首次启动时的资源拉取。 |

## 输出说明

当部署输出会驱动用户下一步操作时，建议优先关注以下字段：

- `nps_address_link`：NPS Web 后台地址，默认访问端口为 `8080`。
- `nps_username` / `nps_password`：模板内置默认后台账号密码；如果你通过自定义 `nps.conf` 覆盖了 Web 配置，请以你注入的实际配置为准。
- `public_ip` / `nps_ip` / `ecs_ip`：实例公网 IP，可用于开放端口、客户端接入或排障。
- `ssh_command`：直接给出 SSH 登录命令。
- `ssh_password` / `ecs_password`：实例 SSH 登录密码，便于首次登录。

## 常见问题

- 如果自定义 `nps.conf` 注入后服务没有起来，优先检查 base64 内容是否完整、是否能正确解码成有效配置文件。
- 如果启动失败，优先排查以下几项：
	1. 腾讯云账户余额是否充足。
	2. 与腾讯云 API 的网络连接是否超时。
	3. ap-beijing 区域对应机型是否售罄或下架。
	4. GitHub 代理地址是否可用，安装包是否下载成功。

## 注意事项

- 默认配置文件已随模板提供，可直接参考同目录下的 [nps.conf](nps.conf)；如需覆盖，请使用 `-e base64_command=...` 传入自定义内容。
- Web 后台默认端口为 `8080`，部署后请按需自行收紧安全组或限制访问来源。

## 附录

- 非 redc 方式使用时，可在 `terraform.tfvars` 中直接填写腾讯云凭据，例如：

```hcl
tencentcloud_secret_id  = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
tencentcloud_secret_key = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
github_proxy            = "https://ghfast.top/github.com"
```

- 如需替换 nps 安装包下载地址，可参考：
	- https://github.com/ehang-io/nps/releases
