# Vultr VPS 场景

## 场景说明

这个场景会在 Vultr 部署一台轻量 VPS，并通过 `init.sh` 启动脚本完成基础初始化。它适合快速拉起一台可直接登录的海外通用主机。

需要注意的是，目录名虽然叫 `hk-vps`，但当前模板默认区域实际是 `sgp`（新加坡），不是香港。

## 前置条件

- 本地 redc 已配置可用的 Vultr API Key，或已设置 `VULTR_API_KEY` 环境变量。
- 账户需要有足够余额，并允许在目标区域创建实例。
- `init.sh` 会作为 Vultr startup script 自动执行；如果你改动模板，需同步检查该脚本内容。

## 快速使用

```bash
redc pull vultr/hk-vps
redc run vultr/hk-vps
redc status [uuid]
redc stop [uuid]
```

如需覆盖区域、实例规格或镜像 ID，可以这样启动：

```bash
redc run vultr/hk-vps \
    -e region=sgp \
    -e plan=vc2-1c-2gb \
    -e os_id=477
```

## 参数说明

| 参数 | 默认值 | 说明 |
| --- | --- | --- |
| `region` | `sgp` | Vultr 区域代码；当前默认是新加坡。 |
| `plan` | `vc2-1c-2gb` | 实例规格。 |
| `os_id` | `477` | 操作系统 ID，当前对应 Ubuntu 22.04 x64。 |

## 输出说明

- `vps_ip` / `main_ip` / `public_ip`：实例公网 IP。
- `password` / `ssh_password`：Vultr 首次创建时返回的默认 root 密码。
- `ssh_user`：默认 SSH 用户名，当前为 `root`。
- `ssh_command`：可直接复制使用的 SSH 命令。
- `vps_os`、`vps_ram`、`vps_disk`、`vps_allowed_bandwidth`、`vps_hostname`：实例元数据，便于快速核对规格。

## 注意事项

- provider 直接从 `VULTR_API_KEY` 读取凭据，不需要再回到旧的 `deploy.sh` 流程里填写 API Key。
- 当前模板的 `label` 和 `hostname` 固定为 `tf-1`，多次运行时主要依赖 Vultr 资源 ID 区分。
- 模板关闭了 IPv6、备份和 DDoS 保护。
- `ssh_password` 依赖 Vultr 返回的 `default_password`；如果你后续改成 SSH key 登录模式，这个输出可能不再可用。
- 如果启动失败，常见原因是 API Key 配置错误、Vultr API 网络超时，或目标区域/规格无可用容量。

## 附录

- `init.sh` 会通过 `vultr_startup_script` 资源自动注入到实例。
- 如需调整初始化逻辑，可查看同目录下的 [init.sh](init.sh)。
