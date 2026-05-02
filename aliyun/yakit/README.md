# 阿里云 Yakit 服务端场景

## 场景说明

这个场景会在阿里云北京地域部署一台 Yakit 服务端主机，自动下载 `yak` 二进制并以 systemd 服务方式启动，适合快速搭建远程扫描或协议分析节点。

部署完成后，你会拿到公网 IP、实例密码、Yakit 监听端口和 SSH 命令；可以直接让 Yakit 客户端连接服务端，或登录主机排查服务状态。

## 前置条件

- 本地 redc 已配置可用的阿里云凭据。
- 账户需要有足够余额，并允许在 `cn-beijing` 地域创建 ECS 实例。
- 本场景从阿里云 OSS 直接下载 `yak` 二进制，不依赖 GitHub 代理。
- 如果你要让客户端从外部访问服务端，请提前确认网络环境允许访问 `yakit_port` 对应端口。

## 快速使用

```bash
redc pull aliyun/yakit
redc run aliyun/yakit
redc status [uuid]
redc stop [uuid]
```

如需覆盖监听端口、实例名或登录密码，可以这样启动：

```bash
redc run aliyun/yakit \
   -e yakit_port=9999 \
   -e instance_name=yakit-server \
   -e instance_password='YourPassword123!'
```

## 参数说明

| 参数 | 默认值 | 说明 |
| --- | --- | --- |
| `instance_name` | `yakit-server` | 实例名称。 |
| `yakit_port` | `8087` | Yakit 服务端监听端口。 |
| `instance_password` | 自动生成 | 实例登录密码；留空时模板会生成随机密码。 |

## 输出说明

- `ecs_ip` / `public_ip`：实例公网 IP。
- `ecs_password` / `ssh_password`：实际生效的登录密码。
- `yakit_port`：当前服务监听端口。
- `ssh_user`：默认 SSH 用户名，当前为 `root`。
- `ssh_command`：可直接复制使用的 SSH 连接命令。

## 注意事项

- 地域固定为 `cn-beijing`。
- 当前实例规格固定为 `ecs.c7a.large`，系统盘为 20GB ESSD；如果该规格在当前地域不可用，启动会失败。
- 虽然模板单独放通了 22 端口和 `yakit_port`，但同时也放开了全部 TCP 和 UDP 入站流量，部署后应按需收紧。
- `yak` 二进制从阿里云 OSS 拉取；如果 OSS 下载失败，服务端不会成功启动。
- 如果启动失败，常见原因是余额不足、API 网络超时、当前地域库存不足，或 `yakit` systemd 服务启动失败。可登录主机执行 `systemctl status yakit` 检查。

## 附录

- `yak` 二进制安装路径：`/usr/local/bin/yak`
- systemd 服务文件路径：`/etc/systemd/system/yakit.service`
- 当前启动命令：`yak grpc --port <yakit_port>`
- 下载地址：`https://yaklang.oss-cn-beijing.aliyuncs.com/yak/latest/yak_linux_amd64`
