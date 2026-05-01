# 阿里云 ECS

## 场景说明

这个场景会在阿里云快速部署一台通用 x86 ECS 主机，默认使用 Debian 12 镜像、20GB 系统盘和 100Mbps 公网带宽，并预装常见运维工具。适合拿来做基础跳板机、临时测试机或通用计算节点。

## 前置条件

- 本地 redc 已配置可用的阿里云凭据。
- 阿里云账户余额需要满足实例创建要求，通常建议大于 200 元。
- 这个场景会自动生成实例密码；如果你有固定密码策略，可以在启动时显式覆盖。

## 快速使用

拉取场景：

```bash
redc pull aliyun/ecs
```

使用默认参数启动：

```bash
redc run aliyun/ecs
```

按需覆盖实例名称或登录密码：

```bash
redc run aliyun/ecs -e instance_name=workbench -e instance_password='YourPassword123!'
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
| `instance_name` | `aliyun_ecs` | ECS 实例名称。 |
| `instance_password` | 自动生成 | ECS 登录密码；留空时模板会自动生成一组随机密码。 |

## 输出说明

- `ecs_ip` / `public_ip`：实例公网 IP。
- `ecs_password` / `ssh_password`：实际生效的登录密码。
- `ssh_user`：默认 SSH 用户名，当前为 `root`。
- `ssh_command`：可直接复制使用的 SSH 命令。

## 注意事项

- 当前实例规格在模板里固定为 `ecs.e-c1m2.large`，镜像固定为 Debian 12 x86，不是一个高度可调的基础模板。
- 默认安全组会放开全部 TCP 入站端口；如果只是通用运维主机，建议部署后按需收敛暴露面。
- 用户数据会尝试卸载阿里云安骑士相关组件，并开启 BBR。
- 如果启动失败，常见原因是余额不足、API 网络超时，或当前地域没有可用库存。
