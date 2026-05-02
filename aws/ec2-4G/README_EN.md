# AWS EC2 4G

## Scene Description

This scene deploys an enhanced ARM64 EC2 host in AWS ap-east-1 (Hong Kong), using `t4g.medium` and a Debian image by default. It is suitable for small scanners, proxy services, or a more capable general-purpose node than the 1G preset.

## Prerequisites

- Your AWS account must have the `ap-east-1` (Hong Kong) region enabled.
- redc must already be configured with working AWS credentials.
- The default instance type is the ARM64 `t4g.medium`. If you override `instance_type`, make sure the selected `ami` uses a compatible architecture.

## Quick Start

```bash
redc pull aws/ec2-4G
redc run aws/ec2-4G
redc status [uuid]
redc stop [uuid]
```

To override the instance type or root volume size:

```bash
redc run aws/ec2-4G -e instance_type=t4g.medium -e volume_size=30
```

## Parameters

| Parameter | Default | Description |
| --- | --- | --- |
| `region` | `ap-east-1` | AWS region. The default is Hong Kong. |
| `instance_type` | `t4g.medium` | EC2 instance type. The current default is a larger ARM64 family. |
| `ami` | `ami-01c9cc5554738042c` | Default Debian ARM64 image. Replace it with a compatible image if you switch to another architecture. |
| `volume_size` | `18` | Root volume size in GB. |

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

If you need to confirm whether the Hong Kong region is enabled, refer to the screenshots below:

![](../../img/redc-2.png)

![](../../img/redc-3.png)
