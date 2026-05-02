# 阿里云文件服务场景

## 场景说明

这个场景会在阿里云北京地域部署一台预装 `simplehttpserver` 的文件服务主机，适合快速起一个可直接登录的轻量文件托管或临时分发节点。

部署完成后，你会拿到公网 IP、实例密码以及可直接复制的 SSH 命令；登录主机后即可使用 `simplehttpserver` 启动临时文件服务。

## 前置条件

- 本地 redc 已配置可用的阿里云凭据。
- 这个场景依赖 `github_proxy` 下载 `simplehttpserver` 压缩包，启动时必须提供可用的 GitHub 代理地址。
- 账户需要有足够余额，并允许在 `cn-beijing` 地域创建 ECS 实例。

## 快速使用

```bash
redc pull aliyun/file
redc run aliyun/file -e github_proxy=https://ghfast.top/github.com
redc status [uuid]
redc stop [uuid]
```

如需同时覆盖实例名或登录密码，可以这样启动：

```bash
redc run aliyun/file \
	-e github_proxy=https://ghfast.top/github.com \
	-e instance_name=fileserver \
	-e instance_password='YourPassword123!'
```

## 参数说明

| 参数 | 默认值 | 说明 |
| --- | --- | --- |
| `instance_name` | `fileserver` | 实例名称。 |
| `github_proxy` | 必填 | GitHub 代理前缀，用于下载 `simplehttpserver` 发布包。 |
| `instance_password` | 自动生成 | 实例登录密码；留空时模板会生成随机密码。 |

## 输出说明

- `ecs_ip` / `public_ip`：实例公网 IP。
- `ecs_password` / `ssh_password`：实际生效的登录密码。
- `ssh_user`：默认 SSH 用户名，当前为 `root`。
- `ssh_command`：可直接复制使用的 SSH 连接命令。

## 注意事项

- 地域固定为 `cn-beijing`。
- 当前实例规格固定为 `ecs.n1.small`，系统盘固定为 30GB；如果该规格在当前地域不可用，启动会失败。
- 默认安全组放开全部 TCP 和 UDP 入站流量，部署后应按需收紧。
- `simplehttpserver` 通过 `github_proxy` 指向的代理地址下载；如果代理不可用，初始化会失败。
- 如果启动失败，常见原因是余额不足、API 网络超时、当前地域库存不足，或 GitHub 代理不可用。

## 附录

- 当前模板下载的是 `simplehttpserver` 官方发布包：
	- https://github.com/projectdiscovery/simplehttpserver
- 下载完成后，二进制会安装到 `/usr/local/bin/simplehttpserver`。
