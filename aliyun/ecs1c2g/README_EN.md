# Aliyun ECS 1C2G

## Scene Description

This scene deploys a small x86 ECS host in the fixed Aliyun region `cn-shanghai`. The instance type is hard-coded to `ecs.n1.small`, the image is Debian 11.7 x86_64, the system disk is 20GB, and the instance gets 100Mbps outbound internet bandwidth. It is suitable for temporary low-spec testing, jump-host, or general administration use cases.

## Prerequisites

- redc must already be configured locally with valid Aliyun credentials.
- Your Aliyun account balance must be sufficient for instance creation; in practice it is usually safer to keep more than CNY 200 available.
- The provider region is fixed to `cn-shanghai`, so this scene is not a flexible multi-region base template.
- If you choose to override `instance_password`, make sure it complies with Aliyun password requirements.

## Quick Start

Pull the scene:

```bash
redc pull aliyun/ecs1c2g
```

Start with the default parameters:

```bash
redc run aliyun/ecs1c2g
```

Override the instance name or login password if needed:

```bash
redc run aliyun/ecs1c2g -e instance_name=workbench -e instance_password='YourPassword123!'
```

Check the running status:

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
| `instance_name` | `ecs1c2g` | ECS instance name. |
| `instance_password` | auto-generated | ECS login password. If left empty, the template generates a random password. |

## Outputs

- `ecs_ip` / `public_ip`: Public IP address of the instance.
- `ecs_password` / `ssh_password`: The effective login password.
- `ssh_user`: Default SSH username, currently `root`.
- `ssh_command`: Copy-ready SSH command.

## Notes

- The instance type is fixed to `ecs.n1.small`, the image is fixed to Debian 11.7 x86_64, and the system disk is fixed to 20GB. Those core resources are not exposed as tunable variables in this scene.
- The default security group opens all inbound TCP and UDP ports. Tighten exposure after deployment if this is not just a temporary host.
- The user data attempts to remove Aliyun Aegis-related components, enables BBR, and installs basic tools such as tmux, screen, and trzsz.
- The availability zone is selected automatically from zones in `cn-shanghai` that support `ecs.n1.small`. Common failure causes are insufficient balance, Aliyun API network timeouts, or regional capacity shortages.
