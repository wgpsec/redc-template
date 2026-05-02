# 腾讯云文件服务场景

## 场景说明

这个场景会在腾讯云北京地域部署一台预装 `simplehttpserver` 的文件服务主机，适合快速起一个可直接登录的轻量文件托管或临时分发节点。

部署完成后，你会拿到公网 IP、实例密码以及可直接复制的 SSH 命令；登录主机后即可使用 `simplehttpserver` 启动临时文件服务。

## 前置条件

- 本地 redc 已配置可用的腾讯云凭据。
- 如果你要临时通过命令行覆盖凭据，请使用 `-e tencentcloud_secret_id=... -e tencentcloud_secret_key=...`，不要把 AK/SK 直接写进版本管理中的 `terraform.tfvars`。
- 这个场景依赖 `github_proxy` 下载 `simplehttpserver` 压缩包，启动时必须提供可用的 GitHub 代理地址。
- 账户需要有足够余额，并允许在 `ap-beijing` 地域创建公网 CVM。

## 快速使用

```bash
redc pull tencent/file
redc run tencent/file -e github_proxy=https://ghfast.top/github.com
redc status [uuid]
redc stop [uuid]
```

如需同时覆盖实例名或登录密码，可以这样启动：

```bash
redc run tencent/file \
	-e github_proxy=https://ghfast.top/github.com \
	-e instance_name=fileserver \
	-e instance_password='YourPassword123!'
```

如果你需要临时传入腾讯云凭据，也应通过变量入口覆盖：

```bash
redc run tencent/file \
	-e github_proxy=https://ghfast.top/github.com \
	-e tencentcloud_secret_id=YOUR_ID \
	-e tencentcloud_secret_key=YOUR_KEY
```

## 参数说明

| 参数 | 默认值 | 说明 |
| --- | --- | --- |
| `instance_name` | `fileserver` | 实例名称。 |
| `tencentcloud_secret_id` | 必填 | 腾讯云 SecretId。通常由 redc provider 配置提供。 |
| `tencentcloud_secret_key` | 必填 | 腾讯云 SecretKey。通常由 redc provider 配置提供。 |
| `github_proxy` | 必填 | GitHub 代理前缀，用于下载 `simplehttpserver` 发布包。 |
| `instance_password` | 自动生成 | 实例登录密码；留空时模板会生成随机密码。 |

## 输出说明

- `ecs_ip` / `public_ip`：实例公网 IP。
- `ecs_password` / `ssh_password`：实际生效的登录密码。
- `ssh_user`：默认 SSH 用户名，当前为 `ubuntu`。
- `ssh_command`：可直接复制使用的 SSH 连接命令。

## 注意事项

- 地域固定为 `ap-beijing`，可用区固定为 `ap-beijing-7`。
- 模板会自动选择腾讯云 S6 机型族中的 2 核 4G 规格，不是任意实例类型都能直接覆盖。
- 默认安全组放开全部入站和出站流量，部署后应按需收紧。
- `simplehttpserver` 通过 `github_proxy` 指向的代理地址下载；如果代理不可用，初始化会失败。
- 如果启动失败，常见原因是余额不足、API 网络超时、区域库存不足，或 GitHub 代理不可用。

## 附录

- 当前模板下载的是 `simplehttpserver` 官方发布包：
	- https://github.com/projectdiscovery/simplehttpserver
- 如需独立修改下载地址，可查看 [main.tf](main.tf) 中对应的 `wget` 命令。
