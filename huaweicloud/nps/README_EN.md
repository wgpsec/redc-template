# Huawei Cloud NPS Scenario

## Description

This scenario deploys NPS (internal network penetration server) on Huawei Cloud for internal network penetration needs in red team penetration testing.

## Configuration

### Auto-generated Resources

- **VPC and Subnet**: Automatically create independent VPC network environment
- **Security Group**: Automatically create and configure security group rules allowing all traffic
- **EIP**: Automatically assign public IP
- **Random Password**: Auto-generate strong random password for SSH login

### Instance Configuration

- **Region**: cn-north-4 (Beijing Four)
- **Availability Zone**: cn-north-4a
- **Image**: Ubuntu 18.04 server 64bit
- **Size**: 1 core 1GB (auto-selected)
- **Authentication**: Password authentication (auto-generated)

## Usage

### 1. Configure Huawei Cloud Credentials

Configure via redc-gui credentials management page, or edit `~/redc/config.yaml`:

```yaml
providers:
  huaweicloud:
    HUAWEICLOUD_ACCESS_KEY: "your_access_key"
    HUAWEICLOUD_SECRET_KEY: "your_secret_key"
```

### 2. Start Scenario

```bash
redc run huaweicloud/nps
```

### 3. Get Connection Info

After scenario starts, redc outputs:

- **nps_ip**: NPS server public IP
- **nps_address_link**: NPS Web management interface address (http://IP:8080)
- **nps_username**: NPS admin username (redone)
- **nps_password**: NPS admin password (1!2A3d4v5s6e)
- **ecs_password**: SSH login password (auto-generated)

### 4. SSH Connection

```bash
# Use redc SSH function
redc ssh <case_id>

# Or manual connection
ssh root@<nps_ip>
# Password is in ecs_password output
```

### Security Recommendations

- After scenario is created, it is recommended to change NPS admin password immediately
- For stricter security policies, you can modify security group rules to restrict access sources
- Remember to destroy the scenario after use to avoid unnecessary costs

## Troubleshooting

### Instance Creation Failed

1. Check if Huawei Cloud credentials are correct
2. Ensure sufficient account balance
3. Check if regional quota is sufficient

### NPS Service Not Started

1. SSH into instance and check logs: `journalctl -u nps`
2. Start service manually: `sudo nps start`
3. Check configuration file: `/etc/nps/conf/nps.conf`

## Related Links

- [NPS Official Documentation](https://github.com/ehang-io/nps)
- [Huawei Cloud Terraform Provider Documentation](https://registry.terraform.io/providers/huaweicloud/huaweicloud/latest/docs)
