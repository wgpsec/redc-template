# Vultr VPS Scenario

## Configure Vultr API Key

### Method 1: Using redc config file (Recommended)

Edit `~/redc/config.yaml`, add Vultr configuration:

```yaml
providers:
  vultr:
    VULTR_API_KEY: "your_vultr_api_key_here"
```

### Method 2: Using Environment Variables

```bash
export VULTR_API_KEY="your_vultr_api_key_here"
```

### Method 3: Configure in deploy.sh (Not Recommended)

In deploy.sh, replace `xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx` with your Vultr API key:

```bash
    -start)
        start_vps "your_vultr_api_key_here"
        ;;
    -stop)
        stop_vps "your_vultr_api_key_here"
        ;;
    -status)
        status_vps "your_vultr_api_key_here"
        ;;
```

## Scenario Description

- **Configuration**: plan vc2-1c-2gb (1 core 2GB RAM)
- **Region**: sgp (Singapore)
- **OS**: os_id 477
- **Startup Script**: Uses init.sh for automatic environment initialization

## Start Scenario with redc

```bash
# Create and start scenario
redc run vultr/hk-vps

# Or step by step
redc plan vultr/hk-vps
redc start <case_id>
```

## Possible Error Reasons

1. **Network connection to Vultr API timed out**
   - Check network connection
   - Check if proxy configuration is needed

2. **Vultr region sold out or this configuration discontinued**
   - Try changing region (modify region in main.tf)
   - Try changing plan (modify plan in main.tf)

3. **API Key configuration error**
   - Confirm API Key is correct
   - Confirm API Key has sufficient permissions

## Update Notes

- Updated Terraform Provider to version 2.22.1 (latest version)
- Added standard SSH output to support redc's SSH operations
- Added Vultr support in redc configuration system
