# CTyun ECS

## Scene Description

This scene creates a basic ECS instance on CTyun and provisions the required VPC, subnet, security group, and public bandwidth configuration around it. It is suitable for quickly bringing up a base host that you can log into directly.

After deployment, you get the instance public IP, SSH username, and SSH password.

## Prerequisites

- redc must already be configured with working CTyun credentials.
- The provider uses a fixed `region_id` in [versions.tf](versions.tf), so the availability zone must match that provider region or creation will fail.
- The template uses the local [userdata](userdata) file as user data input. If you run Terraform standalone, do not remove that file.
- The current template does not auto-generate an instance password, so you should pass `instance_password` explicitly.

## Quick Start

```bash
redc pull ctyun/ecs
redc run ctyun/ecs -e instance_password='YourPassword123!'
redc status [uuid]
redc stop [uuid]
```

To override the availability zone, instance name, flavor, or image ID:

```bash
redc run ctyun/ecs \
  -e availability_zone=cn-huadong1-jsnj1A-public-ctcloud \
  -e instance_name=ctyun-ecs \
  -e instance_flavor_id=YOUR_FLAVOR_ID \
  -e instance_image_id=YOUR_IMAGE_ID \
  -e instance_password='YourPassword123!'
```

## Parameters

| Parameter | Default | Description |
| --- | --- | --- |
| `availability_zone` | `cn-huadong1-jsnj1A-public-ctcloud` | Availability zone name. It must match the provider's fixed region_id. |
| `instance_name` | `redc-ecs` | Instance name. The current default is a fixed string; the random-name branch is only used if you explicitly pass an empty string. |
| `instance_flavor_id` | auto-discovered | Instance flavor ID. If left empty, the template chooses a 2 vCPU / 4 GB x86 flavor from the `CPU_S7` series. |
| `instance_image_id` | auto-discovered | Image ID. If left empty, the template queries the public `Debian 13.1` image. |
| `instance_password` | empty | Instance password. The current template does not auto-generate one, so you should pass it explicitly. |
| `region` | `cn-gd` | Reserved variable. The current template does not use it for provider or resource creation. |

## Outputs

- `instance_id`: ECS instance ID.
- `instance_name`: ECS instance name.
- `ecs_ip` / `public_ip`: Instance public IP address.
- `ssh_user`: Default SSH username, currently `root`.
- `ssh_password`: Current instance password.
- `ssh_command`: Copy-ready SSH command.

## Notes

- The provider in [versions.tf](versions.tf) uses a fixed UUID-style `region_id`, not a human-readable region string like `cn-gd`.
- Although `access_key` and `secret_key` exist in `variables.tf`, the current template does not wire them into the provider. Real credentials should still come from the redc provider configuration.
- The system disk is fixed to 40 GB SATA, billing is fixed to on-demand, and bandwidth is fixed to 100.
- The security group opens all inbound and outbound traffic by default. Tighten access after deployment if needed.
- Common failure causes are insufficient balance, missing credentials, an availability zone that does not match the provider region, or the absence of an explicit usable password.

## Appendix

- `userdata` currently only writes a test log, so initialization is intentionally minimal.
- The template adds random prefixes to VPC, subnet, and security group names to avoid collisions.
