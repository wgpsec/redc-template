# 阿里云 JNDI 演练场景

## 场景说明

这个场景会在阿里云上海地域部署一台预置 JDK8、JNDIExploit、java-chains、MemShellParty 和 `simplehttpserver` 的 JNDI 演练主机，适合快速准备漏洞复现、链路验证或本地对抗测试环境。

部署完成后，你会拿到公网 IP、实例密码和 SSH 命令；登录主机后即可直接使用预装工具链开展验证。

## 前置条件

- 本地 redc 已配置可用的阿里云凭据。
- 这个场景依赖 `github_proxy` 下载多份 JDK 与 JNDI 工具包，启动时必须提供可用的 GitHub 代理地址。
- 账户需要有足够余额，并允许在 `cn-shanghai` 地域创建 ECS 实例。

## 快速使用

```bash
redc pull aliyun/jndi
redc run aliyun/jndi -e github_proxy=https://ghfast.top/github.com
redc status [uuid]
redc stop [uuid]
```

如需同时覆盖实例名或登录密码，可以这样启动：

```bash
redc run aliyun/jndi \
  -e github_proxy=https://ghfast.top/github.com \
  -e instance_name=jndi-lab \
  -e instance_password='YourPassword123!'
```

## 参数说明

| 参数 | 默认值 | 说明 |
| --- | --- | --- |
| `instance_name` | `jndi` | 实例名称。 |
| `github_proxy` | 必填 | GitHub 代理前缀，用于下载 JDK8、JNDIExploit、java-chains 等依赖。 |
| `instance_password` | 自动生成 | 实例登录密码；留空时模板会生成随机密码。 |

## 输出说明

- `ecs_ip` / `public_ip`：实例公网 IP。
- `ecs_password` / `ssh_password`：实际生效的登录密码。
- `ssh_user`：默认 SSH 用户名，当前为 `root`。
- `ssh_command`：可直接复制使用的 SSH 连接命令。

## 注意事项

- 地域固定为 `cn-shanghai`。
- 当前实例规格固定为 `ecs.n1.small`，系统盘固定为 20GB；如果该规格在当前地域不可用，启动会失败。
- 默认安全组放开全部 TCP 和 UDP 入站流量，部署后应按需收紧。
- 这个场景下载依赖较多，即使实例已经创建成功，首次初始化后通常仍建议等待几分钟，再通过 `java -version` 或工具文件路径做确认。
- 如果启动失败，常见原因是余额不足、API 网络超时、当前地域库存不足、GitHub 代理不可用，或 JDK 安装中途失败。

## 附录

- 主要工具和路径：
	- JDK8：`/usr/local/java/jdk1.8.0_321`
	- `java-chains`：`/root/java-chains`
	- `JNDI-Injection-Exploit`：`/root/JNDI-Injection-Exploit-1.0-SNAPSHOT-all.jar`
	- `MemShellParty`：`/root/boot-2.5.0.jar`
	- `simplehttpserver`：`/usr/local/bin/simplehttpserver`
- 其余 JNDIExploit 解压目录会落在 `/root` 下，适合登录后直接检查。
