# Aliyun JNDI Practice Scenario

## Scene Description

This scene deploys an Aliyun host in the Shanghai region with JDK8, JNDIExploit, java-chains, MemShellParty, and `simplehttpserver` preinstalled. It is suitable for quickly preparing a JNDI practice environment for reproduction, payload verification, or local testing.

After deployment, you get the public IP, instance password, and SSH command. Once logged in, you can use the preinstalled toolchain directly.

## Prerequisites

- redc must already be configured with working Aliyun credentials.
- This scene depends on `github_proxy` to download multiple JDK and JNDI-related packages, so you must provide a working GitHub proxy URL when starting it.
- Your account must have enough balance and permission to create ECS instances in `cn-shanghai`.

## Quick Start

```bash
redc pull aliyun/jndi
redc run aliyun/jndi -e github_proxy=https://ghfast.top/github.com
redc status [uuid]
redc stop [uuid]
```

To override the instance name or login password at the same time:

```bash
redc run aliyun/jndi \
  -e github_proxy=https://ghfast.top/github.com \
  -e instance_name=jndi-lab \
  -e instance_password='YourPassword123!'
```

## Parameters

| Parameter | Default | Description |
| --- | --- | --- |
| `instance_name` | `jndi` | Instance name. |
| `github_proxy` | required | GitHub proxy prefix used to download JDK8, JNDIExploit, java-chains, and related tooling. |
| `instance_password` | auto-generated | Instance login password. If left empty, the template generates a random one. |

## Outputs

- `ecs_ip` / `public_ip`: Instance public IP address.
- `ecs_password` / `ssh_password`: Effective login password.
- `ssh_user`: Default SSH username, currently `root`.
- `ssh_command`: Copy-ready SSH command.

## Notes

- The region is fixed to `cn-shanghai`.
- The current instance type is fixed to `ecs.n1.small`, with a 20 GB system disk. If that instance type is unavailable in the region, startup fails.
- The default security group allows all inbound TCP and UDP traffic. Tighten access after deployment if the host is not meant to remain fully exposed.
- This scene downloads many dependencies. Even after the instance is created, it is normal to wait a few more minutes before verifying with `java -version` or checking the expected files.
- Common failure causes are insufficient balance, Aliyun API network timeouts, regional capacity shortages, a broken GitHub proxy, or a failed JDK install.

## Appendix

- Main tool paths:
	- JDK8: `/usr/local/java/jdk1.8.0_321`
	- `java-chains`: `/root/java-chains`
	- `JNDI-Injection-Exploit`: `/root/JNDI-Injection-Exploit-1.0-SNAPSHOT-all.jar`
	- `MemShellParty`: `/root/boot-2.5.0.jar`
	- `simplehttpserver`: `/usr/local/bin/simplehttpserver`
- Other JNDIExploit extraction directories are placed under `/root` for direct inspection after login.
