# 腾讯云 CVM

## 场景说明

这个场景会在腾讯云北京地域快速部署一台公网可达的 CVM，自动安装 wget、curl、tmux、Python3 等常用工具，并返回可直接使用的 SSH 信息。适合临时测试、开发调试或通用主机场景。

## 前置条件

- 本地 redc 已配置可用的腾讯云凭据。
- 如果你通过命令行临时覆盖变量，请使用 `-e tencentcloud_secret_id=... -e tencentcloud_secret_key=...`，不要把 AK/SK 直接写进版本管理中的 `terraform.tfvars`。
- 账户需要有足够余额，并允许在北京地域创建按量 CVM。

## 快速使用

拉取场景：

```bash
redc pull tencent/cvm
```

使用默认参数启动：

```bash
redc run tencent/cvm
```

按需覆盖实例名或登录密码：

```bash
redc run tencent/cvm -e instance_name=lab-cvm -e instance_password='YourPassword123!'
```

如果你需要临时传入腾讯云凭据，也应通过变量入口覆盖：

```bash
redc run tencent/cvm -e tencentcloud_secret_id=YOUR_ID -e tencentcloud_secret_key=YOUR_KEY
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
| `instance_name` | `cvm` | CVM 实例名称。 |
| `tencentcloud_secret_id` | 必填 | 腾讯云 SecretId。通常由 redc provider 配置提供。 |
| `tencentcloud_secret_key` | 必填 | 腾讯云 SecretKey。通常由 redc provider 配置提供。 |
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
- 用户数据会尝试卸载腾讯云监控与安全组件。
- 如果启动失败，常见原因是余额不足、API 网络超时，或当前地域/可用区库存不足。
