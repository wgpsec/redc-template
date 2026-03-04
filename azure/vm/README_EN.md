# Usage

1. **Must** configure according to the notes before use (if empty, no configuration needed)
2. Usage commands are as follows:

Pull
```
redc pull azure/vm
```

Start
```
redc run azure/vm
```

Query
```
redc status [uuid]
```

Stop
```
redc stop [uuid]
```

# Notes

**Azure Credentials Configuration**

Azure service credentials need to be configured. See [redc credentials management](../../README.md)

```yaml
# ~/redc/config.yaml
providers:
  azure:
    ARM_CLIENT_ID: "your-client-id"
    ARM_CLIENT_SECRET: "your-client-secret"
    ARM_SUBSCRIPTION_ID: "your-subscription-id"
    ARM_TENANT_ID: "your-tenant-id"
```

**Region Description**

Default region is `West Europe` (Western Europe)

**Quota Issues**

Creating a VM on Azure requires:

1. **Regional quota**: Target region needs available vCPU quota
2. **SKU availability**: Selected VM size needs available capacity in that region

If you encounter these errors:
- `SkuNotAvailable`: VM size not available in current region → Change `vm_size` or `location`
- `quota exceeded`: vCPU quota insufficient → Apply for quota increase in Azure portal, or change region

**Default Configuration**

| Parameter | Default Value |
|-----------|--------------|
| VM Size | Standard_D2a_v4 |
| Region | West Europe |
| OS Image | Ubuntu 18.04 LTS |
| Username | redcadmin |
| Password | Auto-generated |

**Custom Parameters**

You can override default configuration via `terraform.tfvars`:

```hcl
instance_password = "YourPassword123"
```
