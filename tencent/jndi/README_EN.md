# Tencent JNDI Practice Scenario

## Scene Description

This scene deploys a Tencent Cloud host in the Beijing region with JDK8, JNDIExploit, java-chains, MemShellParty, and `simplehttpserver` preinstalled. It is suitable for quickly preparing a JNDI practice environment for reproduction, payload verification, or local testing.

After deployment, you get the public IP, instance password, and SSH command. Once logged in, you can use the preinstalled toolchain directly.

## Prerequisites

- redc must already be configured with working Tencent Cloud credentials.
- If you need to override credentials temporarily from the CLI, use `-e tencentcloud_secret_id=... -e tencentcloud_secret_key=...`. Do not store live AK/SK values in a tracked `terraform.tfvars` file.
- This scene depends on `github_proxy` to download multiple JDK and JNDI-related packages, so you must provide a working GitHub proxy URL when starting it.
- Your account must have enough balance and permission to create public CVM instances in `ap-beijing`.

## Quick Start

```bash
redc pull tencent/jndi
redc run tencent/jndi -e github_proxy=https://ghfast.top/github.com
redc status [uuid]
redc stop [uuid]
```

To override the instance name or login password at the same time:

```bash
redc run tencent/jndi \
  -e github_proxy=https://ghfast.top/github.com \
  -e instance_name=jndi-lab \
  -e instance_password='YourPassword123!'
```

## Parameters

| Parameter | Default | Description |
| --- | --- | --- |
| `instance_name` | `jndi` | Instance name. |
| `tencentcloud_secret_id` | required | Tencent Cloud SecretId. In normal usage this should come from the redc provider configuration. |
| `tencentcloud_secret_key` | required | Tencent Cloud SecretKey. In normal usage this should come from the redc provider configuration. |
| `github_proxy` | required | GitHub proxy prefix used to download JDK8, JNDIExploit, java-chains, and related tooling. |
| `instance_password` | auto-generated | Instance login password. If left empty, the template generates a random one. |

## Outputs

- `ecs_ip` / `public_ip`: Instance public IP address.
- `ecs_password` / `ssh_password`: Effective login password.
- `ssh_user`: Default SSH username, currently `ubuntu`.
- `ssh_command`: Copy-ready SSH command.

## Notes

- The region is fixed to `ap-beijing`, and the availability zone is fixed to `ap-beijing-7`.
- The template automatically selects a 2 vCPU / 4 GB instance from the Tencent Cloud S6 family. This is not a fully arbitrary instance-type scene.
- The default security group allows all inbound and outbound traffic. Tighten access after deployment if the host is not meant to remain fully exposed.
- This scene downloads many dependencies. Even after the instance is created, it is normal to wait a few more minutes before verifying with `java -version` or checking the expected files.
- Common failure causes are insufficient balance, Tencent Cloud API network timeouts, capacity shortages in the target region, a broken GitHub proxy, or a failed JDK install.

## Appendix

- Main tool paths:
	- JDK8: `/usr/local/java/jdk1.8.0_321`
	- `java-chains`: `/root/java-chains`
	- `JNDI-Injection-Exploit`: `/root/JNDI-Injection-Exploit-1.0-SNAPSHOT-all.jar`
	- `MemShellParty`: `/root/boot-2.5.0.jar`
	- `simplehttpserver`: `/usr/local/bin/simplehttpserver`
- Other JNDIExploit extraction directories are placed under `/root` for direct inspection after login.
