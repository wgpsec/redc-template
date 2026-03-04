# Usage

1. **Must** configure according to the notes before use (if empty, no configuration needed)
2. Usage commands are as follows:

Pull
```
redc pull gcp/compute_instance
```

Start
```
redc run gcp/compute_instance
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

**GCP Credentials Configuration**

GCP service account JSON credentials file path needs to be configured. See [redc credentials management](../../README.md)

```yaml
# ~/redc/config.yaml
providers:
  google:
    GOOGLE_APPLICATION_CREDENTIALS: "/path/to/your-service-account.json"
    project: "your-project-id"
    region: "us-central1"
```

**Region Configuration**

Default region is us-central1 (Iowa)

If starting the scenario fails, possible reasons:
1. Network connection to GCP API timed out
2. GCP project has not enabled Compute Engine API
3. Service account permissions insufficient
4. No available resources in that region
