# DNSLog 场景

## 场景说明

该场景会在 AWS ap-east-1 区域部署一台内置 pdnslog 和前端页面的 DNSLog 服务器，适合做 DNS 回连验证、带外探测和基础回显收集。

部署完成后，你会得到公网 IP、Web 访问地址、Web 登录凭据以及 SSH 连接命令；如果已经配置 Cloudflare 凭据，当前插件会尝试自动更新 `ns1.<主域>` 的 A 记录，但其他解析关系仍需你按实际场景确认或补齐。

## 前置条件

- 需要可用的 AWS 凭据，并确保已开通 ap-east-1（香港）区域。
- 该模板使用 ARM64 架构实例，需确保当前账号在该区域可以创建对应实例。
- 需要准备一个用于 DNSLog 的域名，例如 `dnslog.com`。
- 如果希望 redc 辅助更新 DNS，请在 `redc config.yaml` 中配置 Cloudflare 的邮箱和 access key / API 凭据；当前自动化主要覆盖 `ns1.<主域>` 的 A 记录。
- 如果不配置 Cloudflare API，也可以在部署完成后手动补 DNS 记录，但需要自行完成解析配置。

## 快速使用

```bash
redc pull aws/dnslog
redc run aws/dnslog -e domain=dnslog.com
redc status [uuid]
redc stop [uuid]
```

其中 `domain` 需要替换成你自己的 DNSLog 域名。

## 参数说明

| 参数名 | 是否必填 | 默认值 | 示例 | 行为影响 |
|--------|----------|--------|------|----------|
| `domain` | 是 | 无 | `dnslog.com` | 用于创建和绑定 DNSLog 域名相关解析，是场景能否正常工作的核心参数。 |
| `username` | 否 | `red123` | `admin` | 控制 DNSLog Web 后台用户名；如需自定义，可修改模板变量或 `terraform.tfvars`。 |
| `password` | 否 | `r1e2d3o4n5e6123` | `StrongPass123` | 控制 DNSLog Web 后台密码；如需自定义，可修改模板变量或 `terraform.tfvars`。 |

## 输出说明

当部署输出会驱动下一步操作时，建议优先关注以下字段：

- `web_link`：基于模板默认凭据拼出的 DNSLog Web 后台访问地址；如果你自定义了 `username` 或 `password`，请改用你的自定义凭据访问。
- `web_user` / `web_pass`：模板默认登录凭据；如果运行时覆盖了 `username` 或 `password`，请以你传入的值为准。
- `public_ip` / `ecs_ip`：实例公网 IP，可用于手动配置 DNS、连通性检查或其他排障。
- `ssh_command`：直接给出 SSH 连接命令，便于登录实例查看服务状态。
- `ssh_private_key_path`：本地生成的私钥路径，配合 `ssh_command` 使用。

## 常见问题

- 如果没有配置 Cloudflare API，部署完成后需要手动补 DNS 记录。至少要确认类似下面的解析关系已经建立：

```text
A  ns1  <实例公网IP>
NS a    ns1.dnslog.com
```

- 即使已经配置 Cloudflare 凭据，当前插件默认也只会更新 `ns1.<主域>` 的 A 记录；`a.<domain>` 的 NS 关系等其他记录仍建议手动核查。

- 如果启动失败，优先排查以下几项：
	1. 与 AWS API 的网络连接是否超时。
	2. ap-east-1 区域是否还有可用实例容量。
	3. AMI 架构与实例规格是否匹配。
	4. Cloudflare DNS 配置是否正确。
	5. Cloudflare 凭据权限是否足够。

## 注意事项

- 该场景固定使用 ap-east-1（香港）区域，使用前先确认区域已启用。

![](../../img/redc-2.png)

![](../../img/redc-3.png)

## 附录

- 模板内静态资源下载链接可按需自行替换。
- `dig.pm` 相关实现可参考：
	- https://github.com/yumusb/DNSLog-Platform-Golang
- 如需替换为自编译版本，也可参考：
	- https://github.com/No-Github/pdnslog/releases/tag/v1.0.0
