# AWS Docker

## Scene Description

This scene deploys an x86_64 EC2 host in AWS ap-east-1 (Hong Kong) with a default `t3.medium`, a Debian x86_64 AMI, and an 18GB root disk. After boot, the instance installs Docker through `f8x -docker` and runs that setup in a background tmux session named `docker`, making it suitable as a ready-to-use Docker base host.

## Prerequisites

- Your AWS account must have the `ap-east-1` (Hong Kong) region enabled.
- redc must already be configured locally with valid AWS credentials.
- If you override `instance_type` or `ami`, make sure the architecture still matches; the default combination is x86_64.
- The first boot needs outbound access to the OS package mirrors and `https://f8x.wgpsec.org/f8x`.

## Quick Start

Pull the scene:

```bash
redc pull aws/docker
```

Start with the default parameters:

```bash
redc run aws/docker
```

Override the instance type or root disk size if needed:

```bash
redc run aws/docker -e instance_type=t3.large -e volume_size=30
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
| `region` | `ap-east-1` | AWS region. The default is Hong Kong. |
| `instance_type` | `t3.medium` | EC2 instance type. The default is an x86_64 shape. |
| `ami` | `ami-01c6db7097043551d` | Default Debian x86_64 AMI. If you switch to an ARM instance type, replace this with a compatible image. |
| `volume_size` | `18` | Root disk size in GB. |

## Outputs

- `public_ip`: Public IP address of the instance.
- `public_dns`: Public DNS name of the instance.
- `ssh_private_key_path`: Path to the locally generated ED25519 SSH private key.
- `ssh_user`: Default SSH username, currently `admin`.
- `ssh_command`: Copy-ready SSH command.

## Notes

- The default security group allows all inbound and outbound traffic, so tighten it after deployment if this is more than a temporary host.
- The user data runs `f8x -docker` in the root-owned tmux session named `docker`; to inspect the install progress, SSH in and run `sudo tmux attach -t docker`.
- The template generates a local ED25519 private key file for SSH access.
- Common failure causes are the region not being enabled, temporary capacity shortages, an architecture mismatch between `instance_type` and `ami`, or failed downloads from `f8x` or the package mirrors.

## Appendix

If you need to confirm whether the Hong Kong region is enabled, refer to the screenshots below:

![](../../img/redc-2.png)

![](../../img/redc-3.png)
