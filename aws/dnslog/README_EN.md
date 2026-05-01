# DNSLog Scenario

## Scene Description

This scenario deploys a DNSLog server in AWS ap-east-1 with built-in pdnslog and its web frontend. It is suitable for DNS callback verification, out-of-band interaction testing, and basic callback collection.

After deployment, you get the public IP, web access link, web credentials, and SSH command. If Cloudflare credentials are already configured, the current plugin will try to update the `ns1.<zone>` A record automatically, but other DNS relationships may still need manual confirmation or completion.

## Prerequisites

- You need working AWS credentials and the ap-east-1 (Hong Kong) region enabled.
- This template uses an ARM64 instance, so the target account must be able to launch the required instance type in that region.
- Prepare a domain for the DNSLog service, such as `dnslog.com`.
- If you want redc to assist with DNS updates, configure your Cloudflare email and access key / API credentials in `redc config.yaml`; the current automation mainly targets the `ns1.<zone>` A record.
- If Cloudflare API is not configured, you can still use the scene, but you must create the required DNS records manually after deployment.

## Quick Start

```bash
redc pull aws/dnslog
redc run aws/dnslog -e domain=dnslog.com
redc status [uuid]
redc stop [uuid]
```

Replace `domain` with your own DNSLog domain.

## Parameters

| Parameter | Required | Default | Example | Behavior Impact |
|-----------|----------|---------|---------|-----------------|
| `domain` | Yes | None | `dnslog.com` | Used to create and bind the DNSLog domain records. The scene cannot work correctly without it. |
| `username` | No | `red123` | `admin` | Controls the DNSLog web username; customize it through template variables or `terraform.tfvars` if needed. |
| `password` | No | `r1e2d3o4n5e6123` | `StrongPass123` | Controls the DNSLog web password; customize it through template variables or `terraform.tfvars` if needed. |

## Outputs

When deployment outputs drive your next step, focus on these fields first:

- `web_link`: DNSLog web console URL built from the template's default credentials; if you override `username` or `password`, use your custom credentials instead.
- `web_user` / `web_pass`: Default template credentials; if `username` or `password` is overridden at runtime, use your supplied values instead.
- `public_ip` / `ecs_ip`: Public IP of the instance, useful for manual DNS setup and troubleshooting.
- `ssh_command`: Ready-to-run SSH command for logging into the instance.
- `ssh_private_key_path`: Local path to the generated SSH private key used by `ssh_command`.

## FAQ

- If Cloudflare API is not configured, you must add the DNS records manually after deployment. At minimum, verify a setup similar to the following:

```text
A  ns1  <instance-public-ip>
NS a    ns1.dnslog.com
```

- Even with Cloudflare credentials configured, the current plugin only updates the `ns1.<zone>` A record by default; the `a.<domain>` NS relationship and other records should still be verified manually.

- If startup fails, check these items first:
	1. Whether the AWS API connection timed out.
	2. Whether ap-east-1 still has instance capacity.
	3. Whether the AMI architecture matches the selected instance type.
	4. Whether the Cloudflare DNS configuration is correct.
	5. Whether the Cloudflare credentials have enough permissions.

## Notes

- This scene is fixed to ap-east-1 (Hong Kong). Confirm the region is enabled before use.

![](../../img/redc-2.png)

![](../../img/redc-3.png)

## Appendix

- Static resource download links in the template can be replaced if needed.
- Reference for the dig.pm-related implementation:
	- https://github.com/yumusb/DNSLog-Platform-Golang
- If you prefer a custom-built binary, you can also refer to:
	- https://github.com/No-Github/pdnslog/releases/tag/v1.0.0
