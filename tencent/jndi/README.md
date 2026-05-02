# 腾讯云 JNDI 演练场景

## 场景说明

这个场景会在腾讯云北京地域部署一台预置 JDK8、JNDIExploit、java-chains、MemShellParty 和 `simplehttpserver` 的 JNDI 演练主机，适合快速准备漏洞复现、链路验证或本地对抗测试环境。

部署完成后，你会拿到公网 IP、实例密码和 SSH 命令；登录主机后即可直接使用预装工具链开展验证。

## 前置条件

- 本地 redc 已配置可用的腾讯云凭据。
- 如果你要临时通过命令行覆盖凭据，请使用 `-e tencentcloud_secret_id=... -e tencentcloud_secret_key=...`，不要把 AK/SK 直接写进版本管理中的 `terraform.tfvars`。
- 这个场景依赖 `github_proxy` 下载多份 JDK 与 JNDI 工具包，启动时必须提供可用的 GitHub 代理地址。
- 账户需要有足够余额，并允许在 `ap-beijing` 地域创建公网 CVM。

## 快速使用

```bash
redc pull tencent/jndi
redc run tencent/jndi -e github_proxy=https://ghfast.top/github.com
redc status [uuid]
redc stop [uuid]
```

如需同时覆盖实例名或登录密码，可以这样启动：

```bash
redc run tencent/jndi \
  -e github_proxy=https://ghfast.top/github.com \
  -e instance_name=jndi-lab \
  -e instance_password='YourPassword123!'
```

## 参数说明

| 参数 | 默认值 | 说明 |
| --- | --- | --- |
| `instance_name` | `jndi` | 实例名称。 |
| `tencentcloud_secret_id` | 必填 | 腾讯云 SecretId。通常由 redc provider 配置提供。 |
| `tencentcloud_secret_key` | 必填 | 腾讯云 SecretKey。通常由 redc provider 配置提供。 |
| `github_proxy` | 必填 | GitHub 代理前缀，用于下载 JDK8、JNDIExploit、java-chains 等依赖。 |
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
- 这个场景下载依赖较多，即使实例已经创建成功，首次初始化后通常仍建议等待几分钟，再通过 `java -version` 或工具文件路径做确认。
- 如果启动失败，常见原因是余额不足、API 网络超时、区域库存不足、GitHub 代理不可用，或 JDK 安装中途失败。

## 附录

- 主要工具和路径：
	- JDK8：`/usr/local/java/jdk1.8.0_321`
	- `java-chains`：`/root/java-chains`
	- `JNDI-Injection-Exploit`：`/root/JNDI-Injection-Exploit-1.0-SNAPSHOT-all.jar`
	- `MemShellParty`：`/root/boot-2.5.0.jar`
	- `simplehttpserver`：`/usr/local/bin/simplehttpserver`
- 其余 JNDIExploit 解压目录会落在 `/root` 下，适合登录后直接检查。
