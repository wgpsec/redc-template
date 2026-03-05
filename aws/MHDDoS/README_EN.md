# Usage

1. **Must** configure according to the notes before use (if empty, no configuration needed)
2. Usage commands are as follows:

Pull
```
redc pull aws/MHDDoS
```

Start
```
redc run aws/MHDDoS
```

Query
```
redc status [uuid]
```

Stop
```
redc stop [uuid]
```

# Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| node | Number of nodes | 1 |
| ddos_target | Attack target (IP or domain) | - |
| ddos_threads | Attack threads | 100 |
| ddos_time | Attack duration (seconds) | 3600 |
| ddos_mode | Attack mode (layer7/layer4) | layer7 |

# Attack Modes

- **layer7**: HTTP Flood, GET/POST flood attack
- **layer4**: TCP/UDP flood attack

# Notes

**Region Configuration**

Enable AWS ap-east-1 (Hong Kong) region

![](../../img/redc-2.png)

![](../../img/redc-3.png)

**Usage Restrictions**

This tool is for **authorized penetration testing only**. DDoS attacks without target authorization are illegal.

If starting the scenario fails, possible reasons:
1. Network connection to AWS API timed out
2. AWS region sold out or instance_type configuration discontinued
3. AMI architecture does not match instance_type
