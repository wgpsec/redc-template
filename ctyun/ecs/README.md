# 天翼云 ECS

## 场景说明

这个场景会在天翼云创建一台基础 ECS 实例，并自动拉起配套的 VPC、子网、安全组和公网带宽配置。适合快速拿到一台可直接登录的基础主机。

部署完成后，你会获得实例公网 IP、SSH 用户名和 SSH 密码。

## 前置条件

- 本地 redc 已配置可用的天翼云凭据。
- 当前 provider 在 [versions.tf](versions.tf) 中固定了 `region_id`，因此可用区必须与该 region_id 对应，否则会创建失败。
- 当前模板通过同目录下的 [userdata](userdata) 文件作为用户数据输入；如果你独立运行 Terraform，不要删除这个文件。
- 当前模板不会自动生成实例密码，建议启动时显式传入 `instance_password`。

## 快速使用

```bash
redc pull ctyun/ecs
redc run ctyun/ecs -e instance_password='YourPassword123!'
redc status [uuid]
redc stop [uuid]
```

如需覆盖可用区、实例名、规格或镜像 ID，可以这样启动：

```bash
redc run ctyun/ecs \
  -e availability_zone=cn-huadong1-jsnj1A-public-ctcloud \
  -e instance_name=ctyun-ecs \
  -e instance_flavor_id=YOUR_FLAVOR_ID \
  -e instance_image_id=YOUR_IMAGE_ID \
  -e instance_password='YourPassword123!'
```

## 参数说明

| 参数 | 默认值 | 说明 |
| --- | --- | --- |
| `availability_zone` | `cn-huadong1-jsnj1A-public-ctcloud` | 可用区名称；必须和 provider 固定的 region_id 匹配。 |
| `instance_name` | `redc-ecs` | 实例名称；当前默认值是固定字符串，只有在你显式传入空字符串时模板才会回退到随机名称。 |
| `instance_flavor_id` | 自动查询 | 实例规格 ID；留空时会自动选择 2C4G、`CPU_S7` 系列的 x86 规格。 |
| `instance_image_id` | 自动查询 | 镜像 ID；留空时会自动查询 `Debian 13.1` 公共镜像。 |
| `instance_password` | 空 | 实例密码；当前模板不会自动生成，建议显式传入。 |
| `region` | `cn-gd` | 预留变量，当前模板未实际用于 provider 或资源创建。 |

## 输出说明

- `instance_id`：ECS 实例 ID。
- `instance_name`：ECS 实例名称。
- `ecs_ip` / `public_ip`：实例公网 IP。
- `ssh_user`：默认 SSH 用户名，当前为 `root`。
- `ssh_password`：当前实例密码。
- `ssh_command`：可直接复制使用的 SSH 连接命令。

## 注意事项

- 当前 provider 在 [versions.tf](versions.tf) 中使用的是固定 UUID 形式的 `region_id`，不是 README 里常见的 `cn-gd` 这类字符串区域名。
- `access_key`、`secret_key` 这两个变量虽然存在于 `variables.tf`，但当前模板并没有把它们接到 provider 配置上；实际凭据仍应由 redc provider 配置提供。
- 系统盘固定为 40GB SATA，计费方式固定为按需，带宽固定为 100。
- 安全组默认放开全部入站和出站流量，部署后应按需收紧。
- 如果启动失败，常见原因是账户余额不足、凭据未正确配置、可用区与 region_id 不匹配，或未显式提供可用密码。

## 附录

- `userdata` 当前只写入一条测试日志，初始化逻辑非常轻。
- 模板会为 VPC、子网和安全组附加随机前缀，避免资源重名。
