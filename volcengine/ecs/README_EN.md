# Usage

1. Configure according to the notes before use (if empty, no configuration needed)
2. Usage commands are as follows:

Pull
```
redc pull volcengine/ecs
```

Start
```
redc run volcengine/ecs
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

## Authentication Configuration

Volcengine access credentials need to be configured. There are two ways:

1. **Environment Variables (Recommended)**
```bash
export VOLCENGINE_ACCESS_KEY="your-access-key"
export VOLCENGINE_SECRET_KEY="your-secret-key"
```

2. **Config File**
Configure in `~/.volcengine/config`

## Common Issues

If starting the scenario fails, possible reasons:
1. Volcengine account balance is insufficient
2. Network connection to Volcengine API timed out
3. Volcengine region sold out or instance_type configuration discontinued
4. Access credentials (AK/SK) not configured correctly

## Scenario Configuration

- **Instance Type**: ecs.e-c1m1.large (2 cores 2GB RAM)
- **Billing**: Pay-as-you-go (PostPaid)
- **System Disk**: 20GB ESSD_PL0
- **OS**: Debian 12
- **Login**: Auto-generated SSH password
- **Region**: Beijing (cn-beijing)
