# UCloud UHost

## 场景说明

这个场景会在 UCloud 创建一台通用 UHost 主机，默认使用 `cn-bj2` 区域、`cn-bj2-05` 可用区、`o-basic-1` 规格，并自动绑定一个公网 EIP。实例镜像默认选择 Debian 12.7，系统盘类型为 `cloud_ssd`，同时会附加一块 20GB 数据盘，适合作为通用基础节点或临时运维主机。

## 前置条件

- 需要准备可用的 UCloud 凭据和项目 ID：`ucloud_public_key`、`ucloud_private_key`、`ucloud_project_id`。
- 这些凭据既可以由本地 redc provider 配置提供，也可以在 `redc run` 时用 `-e` 显式覆盖。
- 建议显式设置 `instance_password`；变量默认值为空，如果不传，输出里的 `ssh_password` 也会为空。
- 如果你自定义 `instance_password`，必须满足 8 到 30 位，并同时包含大小写字母、数字和特殊字符。

## 快速使用

拉取场景：

```bash
redc pull ucloud/uhost
```

启动时显式传入必需凭据和登录密码：

```bash
redc run ucloud/uhost \
  -e ucloud_public_key=YOUR_PUBLIC_KEY \
  -e ucloud_private_key=YOUR_PRIVATE_KEY \
  -e ucloud_project_id=YOUR_PROJECT_ID \
  -e instance_password='YourPassword123!'
```

按需覆盖可用区、实例名或实例规格：

```bash
redc run ucloud/uhost \
  -e ucloud_public_key=YOUR_PUBLIC_KEY \
  -e ucloud_private_key=YOUR_PRIVATE_KEY \
  -e ucloud_project_id=YOUR_PROJECT_ID \
  -e instance_password='YourPassword123!' \
  -e availability_zone=cn-bj2-05 \
  -e instance_name=redc-uhost \
  -e instance_type=o-basic-1
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
| `region` | `cn-bj2` | UCloud 区域。 |
| `ucloud_public_key` | 空 | UCloud API Public Key。 |
| `ucloud_private_key` | 空 | UCloud API Private Key。 |
| `ucloud_project_id` | 空 | UCloud 项目 ID。 |
| `availability_zone` | `cn-bj2-05` | 实例可用区。 |
| `instance_name` | `redc-uhost` | UHost 实例名称。 |
| `instance_type` | `o-basic-1` | UHost 实例规格。 |
| `instance_password` | 空 | Root 登录密码，建议显式传入。 |

## 输出说明

- `instance_id`：UHost 实例 ID。
- `instance_name`：UHost 实例名称。
- `private_ip`：实例内网 IP。
- `public_ip`：绑定 EIP 后的公网 IP。
- `ssh_user`：默认 SSH 用户名，当前为 `root`。
- `ssh_password`：实例密码，直接来自 `instance_password`。
- `ssh_command`：可直接复制使用的 SSH 命令。

## 注意事项

- Provider 地域由 `region` 控制，但镜像查询会基于 `availability_zone` 选择 Debian 12.7 基础镜像；如果改区或改可用区，需确认该区仍有匹配镜像。
- 模板会创建一个新的 VPC、子网、EIP，并为实例附加 20GB `cloud_ssd` 数据盘。
- 当前模板直接使用 UCloud 推荐的 `recommend_web` 安全组，而不是在场景里自建更细粒度规则；如果要长期暴露公网服务，建议部署后自行收紧。
- 模板没有额外 user_data 初始化逻辑，因此这是一台相对干净的 Debian 基础主机。
