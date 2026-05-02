# 阿里云 ECS 1C2G

## 场景说明

这个场景会在阿里云固定地域 `cn-shanghai` 部署一台轻量 x86 ECS 主机，实例规格固定为 `ecs.n1.small`，镜像为 Debian 11.7 x86_64，系统盘大小 20GB，并默认提供 100Mbps 公网带宽。适合需要低配基础节点的临时测试、跳板或通用运维用途。

## 前置条件

- 本地 redc 已配置可用的阿里云凭据。
- 阿里云账户余额需要满足实例创建要求，通常建议大于 200 元。
- 模板里的 provider 地域固定为 `cn-shanghai`，这个场景不是一个可自由切换地域的通用模板。
- 如果你准备自定义 `instance_password`，需要确保它符合阿里云密码策略。

## 快速使用

拉取场景：

```bash
redc pull aliyun/ecs1c2g
```

使用默认参数启动：

```bash
redc run aliyun/ecs1c2g
```

按需覆盖实例名称或登录密码：

```bash
redc run aliyun/ecs1c2g -e instance_name=workbench -e instance_password='YourPassword123!'
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
| `instance_name` | `ecs1c2g` | ECS 实例名称。 |
| `instance_password` | 自动生成 | ECS 登录密码；留空时模板会自动生成随机密码。 |

## 输出说明

- `ecs_ip` / `public_ip`：实例公网 IP。
- `ecs_password` / `ssh_password`：实际生效的登录密码。
- `ssh_user`：默认 SSH 用户名，当前为 `root`。
- `ssh_command`：可直接复制使用的 SSH 命令。

## 注意事项

- 这个场景的实例规格固定为 `ecs.n1.small`，镜像固定为 Debian 11.7 x86_64，系统盘固定 20GB，不支持通过变量直接切换这些核心资源。
- 默认安全组会放开全部 TCP 和 UDP 入站端口；如果只是普通基础主机，建议部署后尽快收紧暴露面。
- 用户数据会尝试卸载阿里云安骑士相关组件，并开启 BBR，同时安装 tmux、screen、trzsz 等基础工具。
- 可用区会从当前地域里自动选择一个支持 `ecs.n1.small` 的可用区；如果启动失败，常见原因是余额不足、API 网络超时或库存不足。
