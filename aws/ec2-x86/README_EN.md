# AWS EC2 x86

## Scene Description

This scene deploys an x86_64 EC2 host in AWS ap-east-1 (Hong Kong), using `t3.medium` and a Debian x86 image by default. It is suitable for x86-only Docker environments, VulHub-style labs, or any workload that is not compatible with ARM.

## Prerequisites

- Your AWS account must have the `ap-east-1` (Hong Kong) region enabled.
- redc must already be configured with working AWS credentials.
- The default instance type is the x86_64 `t3.medium`. If you override `instance_type`, make sure the selected `ami` uses a compatible architecture.

## Quick Start

```bash
redc pull aws/ec2-x86
redc run aws/ec2-x86
redc status [uuid]
redc stop [uuid]
```

To override the instance type or root volume size:

```bash
redc run aws/ec2-x86 -e instance_type=t3.medium -e volume_size=30
```

## Parameters

| Parameter | Default | Description |
| --- | --- | --- |
| `region` | `ap-east-1` | AWS region. The default is Hong Kong. |
| `instance_type` | `t3.medium` | EC2 instance type. The current default is an x86_64 family. |
| `ami` | `ami-01c6db7097043551d` | Default Debian x86_64 image. Replace it with a compatible image if you switch to ARM. |
| `volume_size` | `20` | Root volume size in GB. |

## Outputs

- `public_ip`: Instance public IP address.
- `public_dns`: Instance public DNS name.
- `ssh_private_key_path`: Path to the locally generated SSH private key.
- `ssh_user`: Default SSH username, currently `admin`.
- `ssh_command`: Copy-ready SSH command.

## Notes

- The template generates a local ED25519 private key file for SSH access.
- The user data installs an iptables rule that blocks access to the `169.254.169.254` metadata endpoint. Tools that depend on instance metadata may be affected.
- The default security group allows all inbound and outbound traffic. Tighten exposure after deployment if needed.
- Common failure causes are the region not being enabled, AWS API network timeouts, or an architecture mismatch between the instance type and AMI.

## Appendix

This scene is better suited for deployments that require x86 compatibility, such as projects with x86-only Docker images or VulHub-style lab environments.
