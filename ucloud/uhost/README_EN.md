# UCloud UHost Scenario

Create a UHost instance on UCloud using Terraform.

## Usage

### 1. Pull Scenario

```bash
redc pull ucloud/uhost
cd ucloud/uhost
```

### 2. Configure Credentials

Configure UCloud credentials in `config.yaml`:

```yaml
providers:
  ucloud:
    public_key: "your_public_key"
    private_key: "your_private_key"
    project_id: "Default"
    region: "cn-bj2"
```

Or via environment variables:

```bash
export UCLOUD_PUBLIC_KEY="your_public_key"
export UCLOUD_PRIVATE_KEY="your_private_key"
export UCLOUD_PROJECT_ID="Default"
```

### 3. Custom Configuration (Optional)

Edit `terraform.tfvars` to modify default configuration:

```hcl
instance_name        = "my-uhost"
instance_type        = "n-standard-2"
availability_zone    = "cn-bj2-05"
image_id            = "uimage/uhost/CentOS_7.6_x64_20G_alibaba"
password             = "YourPassword123"
```

### 4. Run Scenario

```bash
redc run ucloud/uhost
```

### 5. Check Status

```bash
redc status
```

### 6. Stop and Destroy

```bash
redc stop
```

## Variable Description

| Variable | Default Value | Description |
|----------|--------------|-------------|
| `region` | cn-bj2 | Region |
| `availability_zone` | cn-bj2-05 | Availability Zone |
| `project_id` | Default | Project ID |
| `instance_name` | redc-uhost | Instance Name |
| `instance_type` | n-standard-1 | Instance Type |
| `image_id` | uimage/uhost/CentOS_7.6_x64_20G_alibaba | Image ID |
| `password` | UCloud2024 | Instance Password |

## Output Description

| Output | Description |
|--------|-------------|
| `instance_id` | Instance ID |
| `instance_name` | Instance Name |
| `private_ip` | Private IP |
| `public_ip` | Public IP |

## Common Availability Zones

- `cn-bj2-05` - Beijing Zone 2-05
- `cn-sh2-03` - Shanghai Zone 2-03
- `cn-gd-02` - Guangzhou Zone

## Notes

1. Ensure sufficient UCloud account balance
2. Default project_id is "Default"
3. Default is pay-as-you-go, no charges after stopping
