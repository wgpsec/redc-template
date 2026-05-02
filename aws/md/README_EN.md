# AWS HackMD/Docker

## Scene Description

This scene deploys an ARM64 EC2 host in AWS ap-east-1 (Hong Kong), installs Docker automatically, and launches a HackMD collaboration service through a `docker-compose.yml` downloaded at runtime. It is suitable for quickly bringing up a temporary online collaborative document node.

## Prerequisites

- Your AWS account must have the `ap-east-1` (Hong Kong) region enabled.
- redc must already be configured with working AWS credentials.
- The default instance type is the ARM64 `t4g.medium`. If you override `instance_type`, make sure the selected `ami` uses a compatible architecture.
- Initialization depends on outbound network access to download `f8x` and the `docker-compose.yml` file. If egress is restricted, service startup may fail.

## Quick Start

```bash
redc pull aws/md
redc run aws/md
redc status [uuid]
redc stop [uuid]
```

To override the instance type or root volume size:

```bash
redc run aws/md -e instance_type=t4g.medium -e volume_size=30
```

## Parameters

| Parameter | Default | Description |
| --- | --- | --- |
| `region` | `ap-east-1` | AWS region. The default is Hong Kong. |
| `instance_type` | `t4g.medium` | EC2 instance type. The current default is an ARM64 family. |
| `ami` | `ami-01c9cc5554738042c` | Default Debian ARM64 image. Replace it with a compatible image if you switch to another architecture. |
| `volume_size` | `18` | Root volume size in GB. |

## Outputs

- `public_ip`: Instance public IP address.
- `public_dns`: Instance public DNS name.
- `md_address_link`: HackMD access URL, exposed on port `3000` by default.
- `ssh_private_key_path`: Path to the locally generated SSH private key.
- `ssh_user`: Default SSH username, currently `admin`.
- `ssh_command`: Copy-ready SSH command.

## Notes

- The template generates a local ED25519 private key file for SSH access.
- The default security group allows all inbound and outbound traffic, and HackMD is exposed on port `3000`.
- The user data first downloads `f8x` to install Docker, then runs `docker compose up -d` inside a `tmux` session. Even after the instance is created, it may take a few more minutes before the service becomes reachable.
- The `docker-compose.yml` download URL is currently hard-coded in the template:
	- https://github.com/No-Github/Archive/releases/download/1.0.8/docker-compose.yml
- Common failure causes are the region not being enabled, AWS API network timeouts, an architecture mismatch between the instance type and AMI, or `f8x` failing to install Docker automatically.

## Appendix

If you need to confirm whether the Hong Kong region is enabled, refer to the screenshots below:

![](../../img/redc-2.png)

![](../../img/redc-3.png)
