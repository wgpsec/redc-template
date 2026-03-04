# Volcengine ECS Template

## Introduction

This is a basic template for creating ECS instances on Volcengine.

## Features

- Automatically creates VPC and subnet
- Configures security group (opens SSH, HTTP, HTTPS ports)
- Assigns public IP
- Supports custom user data scripts
- Supports custom instance password

## Usage

### Required Parameters

- `region`: Volcengine region (e.g., `cn-beijing`)
- `instance_type`: Instance type (e.g., `ecs.g3i.large`)

### Optional Parameters

- `instance_name`: Instance name (default: `volcengine-ecs`)
- `instance_password`: Instance password (if not set, key-based login is required)
- `system_disk_size`: System disk size in GB (default: `40`)
- `internet_max_bandwidth_out`: Public bandwidth in Mbps (default: `1`)
- `userdata`: User data script (optional)

## Outputs

- `instance_id`: Instance ID
- `instance_name`: Instance name
- `public_ip`: Public IP address
- `private_ip`: Private IP address
- `region`: Region
- `instance_type`: Instance type

## Notes

1. Ensure your Volcengine account has sufficient quota
2. Instance password must comply with Volcengine's password policy
3. System disk type is fixed at `ESSD_PL0` (Standard Cloud Disk)
4. Default image is veLinux 1.0 CentOS compatible version

## Cost Estimation

- ECS instance fees are charged based on instance type and usage duration
- Public bandwidth is charged by actual usage or fixed bandwidth
- System disk is charged by capacity and type

## Example

```hcl
region                      = "cn-beijing"
instance_type               = "ecs.g3i.large"
instance_name               = "my-server"
instance_password           = "MyPassword123!"
system_disk_size            = 40
internet_max_bandwidth_out  = 5
userdata                    = <<-EOT
#!/bin/bash
yum update -y
yum install -y nginx
systemctl start nginx
systemctl enable nginx
EOT
```
