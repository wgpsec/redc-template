# Aliyun File Service Scenario

## Scene Description

This scene deploys an Aliyun host in the Beijing region with `simplehttpserver` preinstalled. It is suitable for quickly bringing up a lightweight file hosting or temporary distribution node that you can log into directly.

After deployment, you get the public IP, instance password, and a copy-ready SSH command. Once logged in, you can use `simplehttpserver` to start a temporary file service.

## Prerequisites

- redc must already be configured with working Aliyun credentials.
- This scene depends on `github_proxy` to download the `simplehttpserver` release archive, so you must provide a working GitHub proxy URL when starting it.
- Your account must have enough balance and permission to create ECS instances in `cn-beijing`.

## Quick Start

```bash
redc pull aliyun/file
redc run aliyun/file -e github_proxy=https://ghfast.top/github.com
redc status [uuid]
redc stop [uuid]
```

To override the instance name or login password at the same time:

```bash
redc run aliyun/file \
	-e github_proxy=https://ghfast.top/github.com \
	-e instance_name=fileserver \
	-e instance_password='YourPassword123!'
```

## Parameters

| Parameter | Default | Description |
| --- | --- | --- |
| `instance_name` | `fileserver` | Instance name. |
| `github_proxy` | required | GitHub proxy prefix used to download the `simplehttpserver` release package. |
| `instance_password` | auto-generated | Instance login password. If left empty, the template generates a random one. |

## Outputs

- `ecs_ip` / `public_ip`: Instance public IP address.
- `ecs_password` / `ssh_password`: Effective login password.
- `ssh_user`: Default SSH username, currently `root`.
- `ssh_command`: Copy-ready SSH command.

## Notes

- The region is fixed to `cn-beijing`.
- The current instance type is fixed to `ecs.n1.small`, with a 30 GB system disk. If that instance type is unavailable in the region, startup fails.
- The default security group allows all inbound TCP and UDP traffic. Tighten access after deployment if the host is not meant to remain fully exposed.
- `simplehttpserver` is downloaded through the URL derived from `github_proxy`; initialization fails if that proxy is unavailable.
- Common failure causes are insufficient balance, Aliyun API network timeouts, regional capacity shortages, or a broken GitHub proxy.

## Appendix

- The current template downloads the official `simplehttpserver` release package:
	- https://github.com/projectdiscovery/simplehttpserver
- After download, the binary is installed at `/usr/local/bin/simplehttpserver`.
