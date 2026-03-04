# CTyun ECS Scenario

Create an ECS instance on CTyun using Terraform.

## Usage

### 1. Pull Scenario

```bash
redc pull ctyun/ecs
cd ctyun/ecs
```

### 2. Configure Credentials

Configure CTyun credentials in `config.yaml`:

```yaml
providers:
  ctyun:
    access_key: "your_access_key"
    secret_key: "your_secret_key"
    region: "cn-gd"
```

Or via environment variables:

```bash
export CTYUN_ACCESS_KEY="your_access_key"
export CTYUN_SECRET_KEY="your_secret_key"
```

### 3. Custom Configuration (Optional)

Edit `terraform.tfvars` to modify default configuration:

```hcl
instance_name  = "my-ecs"
instance_type = "s3.medium.2"
region        = "cn-gd"
```

### 4. Run Scenario

```bash
redc run ctyun/ecs
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
| `region` | cn-gd | Region, e.g., cn-gd, cn-sh |
| `instance_name` | redc-ecs | Instance name |
| `instance_type` | s3.medium.1 | Instance type |
| `image_id` | (empty) | Image ID, leave empty to use default |
| `password` | (auto-generated) | Instance password |

## Output Description

| Output | Description |
|--------|-------------|
| `instance_id` | Instance ID |
| `instance_name` | Instance name |
| `private_ip` | Private IP |
| `ssh_user` | SSH username |
| `ssh_password` | SSH password |

## Common Regions

- `cn-gd` - Guangdong
- `cn-sh` - Shanghai
- `cn-bj` - Beijing

## Notes

1. Ensure sufficient CTyun account balance
2. Instance type and region can be adjusted as needed
