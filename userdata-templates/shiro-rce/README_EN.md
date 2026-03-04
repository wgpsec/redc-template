# Shiro RCE (CVE-2020-1957)

## Vulnerability Description

Apache Shiro is a powerful security framework for authentication, authorization, encryption, and session management. CVE-2020-1957 is an Apache Shiro authentication bypass vulnerability. Attackers can bypass authentication by constructing special URL paths.

## CVE Information

- **CVE ID**: CVE-2020-1957
- **Vulnerability Type**: RCE / Authentication Bypass
- **Severity**: High
- **Affected Versions**: Shiro < 1.5.2

## Environment Information

- **Image**: vulhub/shiro:1.4.2
- **Port**: 8080
- **Service**: Shiro RCE testing environment

## Usage

1. Execute the userdata script on the cloud server
2. The script will automatically install Docker and start the Shiro vulnerability environment
3. Access `http://<your-ip>:8080` for testing

## Testing Method

```bash
# Construct authentication bypass request
curl -X GET "http://<your-ip>:8080/xxx/../admin/page"
```

## Notes

- This environment is for security research only
- Please restrict access sources in the firewall
- Please delete the environment in time after testing

## References

- [Vulhub Shiro Vulnerability Environment](https://github.com/vulhub/vulhub/tree/master/shiro/CVE-2020-1957)
- [NVD CVE-2020-1957](https://nvd.nist.gov/vuln/detail/CVE-2020-1957)
