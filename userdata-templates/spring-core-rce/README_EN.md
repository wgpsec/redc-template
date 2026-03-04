# Spring Core RCE (CVE-2022-22965)

## Vulnerability Description

Spring Framework remote code execution vulnerability. Attackers can exploit SpEL expression injection to execute arbitrary code. This vulnerability exists in Spring Framework's parameter binding mechanism. By constructing special request parameters, SpEL expression execution can be triggered.

## CVE Information

- **CVE ID**: CVE-2022-22965
- **Vulnerability Type**: RCE (Remote Code Execution)
- **Severity**: Critical
- **Affected Versions**: Spring Framework 5.3.0 ~ 5.3.17

## Environment Information

- **Image**: vulhub/spring-core-rce
- **Port**: 8080
- **Service**: Spring Core RCE testing environment

## Usage

1. Execute the userdata script on the cloud server
2. The script will automatically install Docker and start the Spring Core vulnerability environment
3. Access `http://<your-ip>:8080` for testing

## Testing Method

```bash
# Send malicious request using curl (needs to be adjusted based on actual environment)
curl -X POST "http://<your-ip>:8080" -d "class.module.classLoader.resources.context.parent.pipeline.first.pattern=%23"
```

## Notes

- This environment is for security research only
- Please restrict access sources in the firewall
- Please delete the environment in time after testing

## References

- [Vulhub Spring Core RCE Vulnerability Environment](https://github.com/vulhub/vulhub/tree/master/spring/CVE-2022-22965)
- [NVD CVE-2022-22965](https://nvd.nist.gov/vuln/detail/CVE-2022-22965)
