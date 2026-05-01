# Aliyun ECS

## Scene Description

This scene deploys a general-purpose x86 ECS host on Aliyun. It uses a Debian 12 image, a 20 GB system disk, and 100 Mbps outbound bandwidth by default, and installs common operations tooling during boot. It is suitable for a jump host, temporary test server, or general compute node.

## Prerequisites

- redc must already be configured with working Aliyun credentials.
- Your Aliyun account needs enough balance to create the instance; in practice, keeping more than 200 RMB available is the safe baseline.
- The scene can auto-generate the instance password, but you can also override it explicitly if your environment requires a fixed password policy.

## Quick Start

Pull the scene:

```bash
redc pull aliyun/ecs
```

Run with defaults:

```bash
redc run aliyun/ecs
```

Override the instance name or login password when needed:

```bash
redc run aliyun/ecs -e instance_name=workbench -e instance_password='YourPassword123!'
```

Check the runtime status:

```bash
redc status [uuid]
```

Stop the scene:

```bash
redc stop [uuid]
```

## Parameters

| Parameter | Default | Description |
| --- | --- | --- |
| `instance_name` | `aliyun_ecs` | ECS instance name. |
| `instance_password` | auto-generated | ECS login password. If left empty, the template generates a random one. |

## Outputs

- `ecs_ip` / `public_ip`: Instance public IP address.
- `ecs_password` / `ssh_password`: Effective login password.
- `ssh_user`: Default SSH username, currently `root`.
- `ssh_command`: Copy-ready SSH command.

## Notes

- The instance type is currently fixed in the template as `ecs.e-c1m2.large`, and the image is fixed to Debian 12 x86. This scene is not a highly tunable base template.
- The default security group opens all inbound TCP ports. Tighten exposure after deployment if the host is only meant for general operations.
- The user data attempts to uninstall Aliyun security agent components and enables BBR.
- Common failure causes are insufficient balance, Aliyun API network timeouts, or capacity shortages in the selected region.
