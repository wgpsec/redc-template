# Tencent CVM

## Scene Description

This scene deploys a public-facing CVM instance in Tencent Cloud Beijing, installs common tools such as wget, curl, tmux, and Python3, and returns ready-to-use SSH access details. It is suitable for temporary testing, development debugging, or general host provisioning.

## Prerequisites

- redc must already be configured with working Tencent Cloud credentials.
- If you need to override credentials from the CLI, use `-e tencentcloud_secret_id=... -e tencentcloud_secret_key=...`. Do not store live AK/SK values in a tracked `terraform.tfvars` file.
- Your account must have enough balance and permission to create pay-as-you-go CVM instances in the Beijing region.

## Quick Start

Pull the scene:

```bash
redc pull tencent/cvm
```

Run with defaults:

```bash
redc run tencent/cvm
```

Override the instance name or login password when needed:

```bash
redc run tencent/cvm -e instance_name=lab-cvm -e instance_password='YourPassword123!'
```

If you need to pass Tencent Cloud credentials temporarily, do it through the generic variable entry:

```bash
redc run tencent/cvm -e tencentcloud_secret_id=YOUR_ID -e tencentcloud_secret_key=YOUR_KEY
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
| `instance_name` | `cvm` | CVM instance name. |
| `tencentcloud_secret_id` | required | Tencent Cloud SecretId. In normal usage this should come from the redc provider configuration. |
| `tencentcloud_secret_key` | required | Tencent Cloud SecretKey. In normal usage this should come from the redc provider configuration. |
| `instance_password` | auto-generated | Instance login password. If left empty, the template generates a random one. |

## Outputs

- `ecs_ip` / `public_ip`: Instance public IP address.
- `ecs_password` / `ssh_password`: Effective login password.
- `ssh_user`: Default SSH username, currently `ubuntu`.
- `ssh_command`: Copy-ready SSH command.

## Notes

- The region is fixed to `ap-beijing`, and the availability zone is fixed to `ap-beijing-7`.
- The template automatically selects a 2 vCPU / 4 GB instance from the Tencent Cloud S6 family. This is not a fully arbitrary instance-type scene.
- The default security group allows all inbound and outbound traffic. Tighten access after deployment if the host is not meant to stay fully exposed.
- The user data attempts to remove Tencent Cloud monitoring and security components.
- Common failure causes are insufficient balance, Tencent Cloud API network timeouts, or capacity shortages in the chosen region and availability zone.
