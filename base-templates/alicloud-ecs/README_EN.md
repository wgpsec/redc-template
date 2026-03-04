# Aliyun ECS Instance Template

This is a Terraform template for creating Aliyun ECS instances.

## Features

- Automatically creates VPC and VSwitch
- Configures security group rules (SSH, HTTP, HTTPS)
- Supports custom instance types and system disk sizes
- Supports user data scripts (user_data)
- Automatically assigns public IP

## Prerequisites

1. Configure Aliyun access credentials:
   - Set environment variables `ALICLOUD_ACCESS_KEY` and `ALICLOUD_SECRET_KEY`
   - Or configure in `~/.aliyun/config.json`

2. Ensure account has sufficient permissions to create ECS, VPC, security groups, etc.

## Configuration Parameters

### Required Parameters

- `region`: Aliyun region (e.g., `cn-hangzhou`, `cn-beijing`)
- `instance_type`: Instance type (e.g., `ecs.t6-c1m1.large`)
- `instance_password`: Instance password (if not provided, system will auto-generate)

### Optional Parameters

- `instance_name`: Instance name (default: `alicloud-ecs-instance`)
- `system_disk_size`: System disk size in GB (default: 40)
- `system_disk_category`: System disk type (default: `cloud_efficiency`)
  - `cloud_efficiency`: Efficiency Cloud Disk (recommended, supported in all regions and instance types)
  - `cloud_ssd`: SSD Cloud Disk (high performance, supported in most regions)
  - `cloud_essd`: ESSD Cloud Disk (ultra-high performance, supported in some regions/instance types)
  - `cloud_essd_entry`: Entry-level ESSD (supported in some regions/instance types)
- `userdata`: User data script
- `internet_max_bandwidth_out`: Public bandwidth in Mbps (default: 1)

## Output Information

- `instance_id`: Instance ID
- `instance_name`: Instance name
- `public_ip`: Public IP address
- `private_ip`: Private IP address
- `region`: Region
- `instance_type`: Instance type
- `ssh_command`: SSH connection command
- `available_zones`: List of all availability zones supporting this instance type
- `selected_zone`: Currently selected availability zone

## Example

Create a basic ECS instance:

```hcl
region        = "cn-hangzhou"
instance_type = "ecs.t6-c1m1.large"
instance_name = "my-ecs-instance"
```

## Notes

1. Instance password requirements: 8-30 characters, must contain uppercase and lowercase letters, and numbers
2. System will automatically select an availability zone that supports the specified instance type
3. Default image is Ubuntu 20.04
4. Public bandwidth is billed by traffic

### Handling Availability Zone Resource Sold Out

If you encounter the following error during deployment:
```
Zone.NotOnSale: The resource in the specified zone is no longer available for sale.
```

This means the instance type is sold out in the selected availability zone. Solution:

1. Check the deployment output `available_zones` to see which availability zones support the instance type
2. Edit the `data.tf` file in the deployment directory, modify the `zone_index` value in the `locals` block:
   ```hcl
   locals {
     zone_index = 1  # Change to 1 to try the second availability zone, 2 for the third, etc.
   }
   ```
3. Run `terraform apply` again
4. Or choose a different instance type

## Resource List

This template will create:

- 1 VPC
- 1 VSwitch
- 1 Security Group
- 4 Security group rules (SSH, HTTP, HTTPS, Outbound)
- 1 ECS Instance (with public IP)
