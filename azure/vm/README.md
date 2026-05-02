# Azure VM

## 场景说明

这个场景会在 Azure `West Europe` 区域创建一台使用密码登录的 Linux 虚拟机，并返回公网 IP 与 SSH 登录信息。当前模板更适合作为参考型 preset，因为仓库元数据已经明确标注：该场景此前因 Azure 配额问题未稳定验证通过。

## 前置条件

- 本地 redc 已配置可用的 Azure 服务主体凭据。
- 目标订阅需要在 `West Europe` 区域具备 `Standard_D2a_v4` 的可用配额和 SKU 容量。
- 当前模板的资源组、网络、网卡、虚拟机名称都是固定字符串；如果同一订阅里已存在同名资源，重复运行会冲突。

## 快速使用

```bash
redc pull azure/vm
redc run azure/vm
redc status [uuid]
redc stop [uuid]
```

如需显式覆盖登录密码，可以这样启动：

```bash
redc run azure/vm -e instance_password='YourPassword123!'
```

## 参数说明

| 参数 | 默认值 | 说明 |
| --- | --- | --- |
| `instance_password` | 自动生成 | 虚拟机管理员密码；留空时模板会生成随机密码。 |

## 输出说明

- `public_ip`：虚拟机公网 IP。
- `ecs_password` / `ssh_password`：实际生效的登录密码。
- `ssh_user`：默认 SSH 用户名，当前为 `redcadmin`。
- `ssh_command`：可直接复制使用的 SSH 连接命令。

## 注意事项

- 区域固定为 `West Europe`。
- VM 规格固定为 `Standard_D2a_v4`，镜像固定为 `Ubuntu 18.04-LTS`。
- 当前模板通过密码方式登录，不使用 SSH key。
- 因为场景元数据已经说明“由于配额问题未跑通，仅记录参考”，所以如果你在当前订阅里遇到 `SkuNotAvailable` 或 `quota exceeded`，这属于已知风险而不是单纯文档缺失。
- 如果启动失败，常见原因是 Azure 凭据配置错误、区域配额不足、SKU 不可用，或固定资源名冲突。

## 附录

- 当前固定资源名包括：资源组 `redc-resources-1`、虚拟机 `test-machine`、网卡 `test-nic`、公网 IP `test-publicip`。
- 当前模板没有暴露 `location` 或 `vm_size` 为用户变量；如果需要更改区域或规格，需要修改 [main.tf](main.tf)。
