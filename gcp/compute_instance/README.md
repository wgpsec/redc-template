# GCP Compute Instance

## 场景说明

这个场景会在 GCP 的 `us-central1-a` 区域部署一台基础 Compute Engine 实例，默认规格为 `e2-micro`，适合快速拿到一台最小化测试主机，并按需覆盖实例规格、镜像或项目 ID。

## 前置条件

- 本地 redc 已配置 GCP 服务账号 JSON 凭据
- 目标项目需要启用 Compute Engine API，并确保服务账号拥有创建实例的权限。
- **必须**在运行时显式覆盖 `GCP_PROJECT_ID`；模板里的默认值只是仓库示例，provider 会直接使用这个变量作为目标项目。

## 快速使用

拉取场景：

```bash
redc pull gcp/compute_instance
```

使用显式项目 ID 启动：

```bash
redc run gcp/compute_instance -e GCP_PROJECT_ID=your-project-id
```

按需覆盖实例规格、可用区或镜像：

```bash
redc run gcp/compute_instance \
  -e GCP_PROJECT_ID=your-project-id \
  -e instance_machine_type=e2-small \
  -e zone=us-central1-b \
  -e image=ubuntu-minimal-2210-kinetic-amd64-v20230126
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
| `GCP_PROJECT_ID` | `redc-488606` | GCP 项目 ID。这个默认值只是仓库示例，实际使用时必须显式覆盖。 |
| `instance_name` | `vm-test` | 实例名称。 |
| `instance_machine_type` | `e2-micro` | 实例规格。 |
| `location` | `us-central1` | 保留变量，当前模板未实际用于资源创建；真正决定落区的是 `zone`。 |
| `zone` | `us-central1-a` | 可用区。 |
| `image` | `ubuntu-minimal-2210-kinetic-amd64-v20230126` | 启动镜像名称。 |

## 输出说明

- `instance_ip` / `public_ip`：实例公网 IP。
- `ssh_user`：模板兼容输出，当前写死为 `ubuntu`，不应直接视为你的实际 GCP 登录用户名。
- `ssh_command`：模板给出的基础连接字符串，主要用于提示目标 IP；不保证可直接完成登录。
- `ssh_private_key_path`：固定为空；这个场景不会像 AWS/Tencent 那样在本地生成私钥文件。

## 注意事项

- GCP 的 SSH 接入方式依赖你当前项目和账号的认证方式；当前模板不会生成本地私钥，也不会决定最终 OS Login 用户名。如果直接使用 `ssh_command` 失败，请改用 `gcloud compute ssh` 或按你的 OS Login / 项目 SSH Key 策略处理。
- 当前资源创建实际使用的是 `zone`；如果你要修改落地区域，请优先显式覆盖 `zone`。
- 如果启动失败，常见原因是 API 网络超时、项目未启用 Compute Engine API、服务账号权限不足，或目标区域没有可用资源。
