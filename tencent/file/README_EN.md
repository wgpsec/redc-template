# Tencent File Service Scenario

## Scene Description

This scene deploys a Tencent Cloud host in the Beijing region with `simplehttpserver` preinstalled. It is suitable for quickly bringing up a lightweight file hosting or temporary distribution node that you can log into directly.

After deployment, you get the public IP, instance password, and a copy-ready SSH command. Once logged in, you can use `simplehttpserver` to start a temporary file service.

## Prerequisites

- redc must already be configured with working Tencent Cloud credentials.
- If you need to override credentials temporarily from the CLI, use `-e tencentcloud_secret_id=... -e tencentcloud_secret_key=...`. Do not store live AK/SK values in a tracked `terraform.tfvars` file.
- This scene depends on `github_proxy` to download the `simplehttpserver` release archive, so you must provide a working GitHub proxy URL when starting it.
- Your account must have enough balance and permission to create public CVM instances in `ap-beijing`.

## Quick Start

```bash
redc pull tencent/file
redc run tencent/file -e github_proxy=https://ghfast.top/github.com
redc status [uuid]
redc stop [uuid]
```

To override the instance name or login password at the same time:

```bash
redc run tencent/file \
	-e github_proxy=https://ghfast.top/github.com \
	-e instance_name=fileserver \
	-e instance_password='YourPassword123!'
```

If you need to pass Tencent Cloud credentials temporarily, do it through the generic variable entry as well:

```bash
redc run tencent/file \
	-e github_proxy=https://ghfast.top/github.com \
	-e tencentcloud_secret_id=YOUR_ID \
	-e tencentcloud_secret_key=YOUR_KEY
```

## Parameters

| Parameter | Default | Description |
| --- | --- | --- |
| `instance_name` | `fileserver` | Instance name. |
| `tencentcloud_secret_id` | required | Tencent Cloud SecretId. In normal usage this should come from the redc provider configuration. |
| `tencentcloud_secret_key` | required | Tencent Cloud SecretKey. In normal usage this should come from the redc provider configuration. |
| `github_proxy` | required | GitHub proxy prefix used to download the `simplehttpserver` release package. |
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
- `simplehttpserver` is downloaded through the URL derived from `github_proxy`; initialization fails if that proxy is unavailable.
- Common failure causes are insufficient balance, Tencent Cloud API network timeouts, capacity shortages in the target region, or a broken GitHub proxy.

## Appendix

- The current template downloads the official `simplehttpserver` release package:
	- https://github.com/projectdiscovery/simplehttpserver
- If you need to change the download source in standalone usage, check the corresponding `wget` command in [main.tf](main.tf).
