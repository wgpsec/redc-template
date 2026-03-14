# AWS EC2 x86 General Scenario

ap-east-1 region, t3.medium instance (x86_64 architecture, 2C4G), pre-installed basic operation tools.

Suitable for deployments requiring x86 compatibility, such as VulHub vulnerability environments and projects with x86-only Docker images.

## Configuration

| Parameter | Value |
|-----------|-------|
| Region | ap-east-1 (Hong Kong) |
| Instance Type | t3.medium |
| Architecture | x86_64 |
| Root Disk | 20GB gp3 |
| AMI | Debian (x86_64) |

## Common Issues

1. Cannot SSH after instance creation: Instance needs 1-2 minutes to initialize
2. AWS region sold out or instance_type configuration discontinued
3. AMI architecture does not match instance_type
