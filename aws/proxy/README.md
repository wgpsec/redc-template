# 多节点代理场景

## 场景说明

该场景会在 AWS ap-east-1 区域批量部署多台基于 shadowsocks-libev 的代理节点，默认创建 10 台 t4g.nano 抢占式实例，适合快速拿到一组可批量接入的代理出口。

部署完成后，你会得到节点公网 IP 列表、批量 SSH 连接命令，以及由插件生成的 Clash 配置文件；如果已经配置 R2 上传能力，还可以把配置文件自动上传到对象存储后再分发使用。

## 前置条件

- 需要可用的 AWS 凭据，并确保已开通 ap-east-1（香港）区域。
- 该模板使用 ARM64 架构实例，需确保当前账号在该区域可以创建对应实例。
- 默认使用抢占式实例，需接受节点数量和可用性可能受库存影响。
- 如果希望自动上传 Clash 配置到 R2，请提前安装并配置 `rclone`，并准备好 Cloudflare R2 存储桶。
- 如果不配置 R2 上传，场景仍可正常使用，只是需要在本地查看插件生成的 Clash 配置文件。

## 快速使用

```bash
redc pull aws/proxy
redc run aws/proxy
redc run aws/proxy -e node=10
redc status [uuid]
redc stop [uuid]
```

默认会创建 10 台节点；如果需要自定义数量，可通过 `-e node=...` 覆盖。

## 参数说明

| 参数名 | 是否必填 | 默认值 | 示例 | 行为影响 |
|--------|----------|--------|------|----------|
| `node` | 否 | `10` | `20` | 控制代理节点数量，数量越多，成本和可用出口数也会相应增加。 |
| `port` | 否 | `60001` | `60010` | 控制生成的 Shadowsocks 服务端口，同时影响 Clash 配置内容。 |
| `password` | 否 | `O9E3b1/OdxCrLkTmWyTL7w==` | `StrongProxyPass123` | 控制代理认证密码，同时影响插件生成的配置文件。 |
| `filename` | 否 | `aws-config.yaml` | `team-proxy.yaml` | 控制本地或上传后的 Clash 配置文件名。 |
| `buckets_name` | 否 | `test` | `proxy-config` | 仅在启用 R2 上传时使用，决定上传目标存储桶。 |
| `buckets_path` | 否 | `/proxyfile/` | `/shared/aws/` | 仅在启用 R2 上传时使用，决定上传路径前缀。 |

## 输出说明

当部署输出会驱动用户下一步操作时，建议优先关注以下内容：

- `public_ip` / `ecs_ip`：代理节点公网 IP 列表，可用于快速盘点节点是否都已拉起。
- `ssh_commands`：批量 SSH 登录命令，便于逐台节点检查服务状态。
- Clash 配置文件：由 `redc-plugin-clash-config` 根据 `port`、`password`、`filename` 生成；如果配置了 R2 上传，还会配合上传插件做进一步分发。

## 常见问题

- 如果没有配置 R2 上传，场景仍可正常使用，直接查看本地生成的 Clash 配置文件即可。
- 如果启动失败，优先排查以下几项：
	1. 与 AWS API 的网络连接是否超时。
	2. ap-east-1 区域是否还有可用抢占式实例容量。
	3. AMI 架构与实例规格是否匹配。
	4. `rclone` 配置是否正确。
	5. R2 存储桶名称或路径配置是否一致。

## 注意事项

- 该场景固定使用 ap-east-1（香港）区域，使用前先确认区域已启用。

![](../../img/redc-2.png)

![](../../img/redc-3.png)

## 附录

- 在 redc 场景执行链路中，Clash 配置由 `redc-plugin-clash-config` 生成，R2 上传由 `redc-plugin-upload-r2` 负责；`deploy.sh` 中的 `upload_to_r2` 更适合独立 Terraform 使用时参考。
- 如需启用 R2 上传，请先安装并配置 `rclone`：
	- https://github.com/rclone/rclone/releases
	- https://dash.cloudflare.com/ 的 R2

![](../../img/redc-1.png)

```text
rclone config
s3
Cloudflare R2 Storage
xxxxxxxxxxxxx
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
https://xxxxxxxxxxxxxxxxxx.r2.cloudflarestorage.com
auto

rclone lsf r2:test
```

- 如需独立使用 `deploy.sh`，也可以调整其中 `upload_to_r2` 函数输出的配置下载 URL，例如：

```text
echo "url : https://这里改成你的 r2 地址/proxyfile/aws-config.yaml"
```
