# 火山引擎 ECS

## 场景说明

这个场景会在火山引擎北京地域部署一台按量计费的 Debian 12 ECS 实例，并自动完成基础运维工具、BBR 和 `trzsz` 的初始化。适合快速拿到一台可直接登录的通用主机。

部署完成后，你会获得公网 IP、实例密码和可直接复制的 SSH 命令。

## 前置条件

- 本地 redc 已配置可用的火山引擎凭据。
- 账户需要有足够余额，并允许在 `cn-beijing` 地域创建按量实例和 EIP。
- 当前模板会在本地运行目录之外创建随机命名的 VPC、子网、安全组和 EIP，不适合要求固定资源命名的场景。

## 快速使用

```bash
redc pull volcengine/ecs
redc run volcengine/ecs
redc status [uuid]
redc stop [uuid]
```

如需覆盖实例名或登录密码，可以这样启动：

```bash
redc run volcengine/ecs \
	-e instance_name=volc-node \
	-e instance_password='YourPassword123!'
```

## 参数说明

| 参数 | 默认值 | 说明 |
| --- | --- | --- |
| `instance_name` | `volcengine_ecs` | 实例名称；当前默认值是固定字符串，只有在你显式传入空字符串时模板才会回退到带随机后缀的命名。 |
| `instance_password` | 自动生成 | 实例登录密码；留空时模板会生成随机密码。 |

## 输出说明

- `ecs_ip` / `public_ip`：实例公网 IP。
- `ecs_password` / `ssh_password`：实际生效的登录密码。
- `ssh_user`：默认 SSH 用户名，当前为 `root`。
- `ssh_command`：可直接复制使用的 SSH 连接命令。

## 注意事项

- 地域固定为 `cn-beijing`。
- 当前实例规格固定为 `ecs.e-c1m1.large`，系统盘固定为 20GB `ESSD_PL0`，计费方式固定为按量付费。
- 镜像通过 `name_regex = "Debian 12"` 动态选择；如果官方镜像命名变化，数据源查询可能失败。
- 模板会自动申请 EIP 并关联到实例。
- 如果启动失败，常见原因是余额不足、API 网络超时、当前地域无可用实例库存，或未正确配置 AK/SK。

## 附录

- 模板会为 EIP、VPC、子网和安全组附加随机后缀，减少重复运行时的名称冲突；实例名只有在传入空字符串时才会走随机后缀分支。
- 用户数据会安装 `curl`、`wget`、`tmux`、`unzip`、`python3-pip`，并开启 BBR。
