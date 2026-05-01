# AWS EC2

## Scene Description

This scene deploys a general-purpose EC2 host in AWS ap-east-1 (Hong Kong). It uses an ARM64 `t4g.small` instance and a Debian image by default, installs common operations tooling, and returns a public IP plus ready-to-use SSH access.

## Prerequisites

- Your AWS account must have the `ap-east-1` (Hong Kong) region enabled.
- redc must already be configured with working AWS credentials.
- If you override `instance_type`, make sure the selected `ami` matches the same CPU architecture; the default combination is ARM64.

## Quick Start

Pull the scene:

```bash
redc pull aws/ec2
```

Run with defaults:

```bash
redc run aws/ec2
```

Override the instance type or root volume size when needed:

```bash
redc run aws/ec2 -e instance_type=t4g.small -e volume_size=30
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
| `region` | `ap-east-1` | AWS region. The default is Hong Kong. |
| `instance_type` | `t4g.small` | EC2 instance type. The default is an ARM64 family. |
| `ami` | `ami-01c9cc5554738042c` | Default Debian ARM64 image. Replace it with a compatible image if you switch to an x86 instance type. |
| `volume_size` | `18` | Root volume size in GB. |

## Outputs

- `public_ip`: Instance public IP address.
- `public_dns`: Instance public DNS name.
- `ssh_private_key_path`: Path to the locally generated SSH private key.
- `ssh_user`: Default SSH username, currently `admin`.
- `ssh_command`: Copy-ready SSH command.

## Notes

- The default security group allows all inbound and outbound traffic. Tighten it after deployment if your use case needs stricter exposure.
- The user data adds an iptables rule to block access to the `169.254.169.254` metadata endpoint.
- Common failure causes are: the region is not enabled, the selected instance family is unavailable in that region, or the `instance_type` and `ami` architectures do not match.

## Appendix

If you need to confirm whether the Hong Kong region is enabled, refer to the screenshots below:

![](../../img/redc-2.png)

![](../../img/redc-3.png)
