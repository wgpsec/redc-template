# Volcengine ECS

## Scene Description

This scene deploys a pay-as-you-go Debian 12 ECS instance in the Volcengine Beijing region and initializes common operations tooling, BBR, and `trzsz`. It is suitable for quickly bringing up a general-purpose host that you can log into directly.

After deployment, you get the public IP, instance password, and a copy-ready SSH command.

## Prerequisites

- redc must already be configured with working Volcengine credentials.
- Your account must have enough balance and permission to create pay-as-you-go ECS instances and EIPs in `cn-beijing`.
- The current template creates randomly suffixed VPC, subnet, security group, and EIP resources, so it is not intended for environments that require fixed resource names.

## Quick Start

```bash
redc pull volcengine/ecs
redc run volcengine/ecs
redc status [uuid]
redc stop [uuid]
```

To override the instance name or login password:

```bash
redc run volcengine/ecs \
	-e instance_name=volc-node \
	-e instance_password='YourPassword123!'
```

## Parameters

| Parameter | Default | Description |
| --- | --- | --- |
| `instance_name` | `volcengine_ecs` | Instance name. The current default is a fixed string; the random-suffix branch is only used if you explicitly pass an empty string. |
| `instance_password` | auto-generated | Instance login password. If left empty, the template generates a random one. |

## Outputs

- `ecs_ip` / `public_ip`: Instance public IP address.
- `ecs_password` / `ssh_password`: Effective login password.
- `ssh_user`: Default SSH username, currently `root`.
- `ssh_command`: Copy-ready SSH command.

## Notes

- The region is fixed to `cn-beijing`.
- The current instance type is fixed to `ecs.e-c1m1.large`, the system disk is fixed to 20 GB `ESSD_PL0`, and the billing model is fixed to pay-as-you-go.
- The image is selected dynamically through `name_regex = "Debian 12"`; if Volcengine changes the public image naming, the data source lookup may fail.
- The template automatically allocates an EIP and associates it with the instance.
- Common failure causes are insufficient balance, Volcengine API network timeouts, lack of capacity in the target region, or incorrectly configured AK/SK credentials.

## Appendix

- The template appends random suffixes to the EIP, VPC, subnet, and security group names to reduce collisions across repeated runs; the instance name only uses the random-suffix branch if an empty string is passed explicitly.
- The user data installs `curl`, `wget`, `tmux`, `unzip`, and `python3-pip`, and enables BBR.
