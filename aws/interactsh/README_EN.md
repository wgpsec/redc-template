# Interactsh Scenario

## Scene Description

This scenario deploys an interactsh-server in AWS ap-east-1. It is suitable for out-of-band interaction testing, blind callback verification, and interactive callback collection.

After deployment, you get the public IP, SSH command, and the service domain that can be used with `https://app.interactsh.com/`. If Cloudflare credentials are already configured, the current plugin will try to update the `ns1.<zone>` A record automatically, but other DNS relationships may still need manual verification.

## Prerequisites

- You need working AWS credentials and the ap-east-1 (Hong Kong) region enabled.
- This template uses an ARM64 instance, so the target account must be able to launch the required instance type in that region.
- Prepare a domain for the interactsh service.
- If you want redc to assist with DNS updates, configure your Cloudflare email and access key / API credentials in `redc config.yaml`; the current automation mainly targets the `ns1.<zone>` A record.
- If Cloudflare API is not configured, you can still use the scene, but you must create the required DNS records manually after deployment.

## Quick Start

```bash
redc pull aws/interactsh
redc run aws/interactsh -e domain=interactsh.example.com
redc status [uuid]
redc stop [uuid]
```

Replace `domain` with your own interactsh domain.

## Parameters

| Parameter | Required | Default | Example | Behavior Impact |
|-----------|----------|---------|---------|-----------------|
| `domain` | Yes | None | `interactsh.example.com` | Defines the domain bound to the interactsh service and used later by the client or web UI. |

## Outputs

When deployment outputs drive your next step, focus on these fields first:

- `web_link`: Fixed as `https://app.interactsh.com/`, used for the interactsh web client.
- `web_domain`: The actual interactsh domain you deployed and will use in the client.
- `public_ip` / `ecs_ip`: Public IP of the instance, useful for manual DNS setup and troubleshooting.
- `ssh_command`: Ready-to-run SSH command for logging into the instance.
- `ssh_private_key_path`: Local path to the generated SSH private key used by `ssh_command`.

## FAQ

- If Cloudflare API is not configured, you must create the required DNS records manually after deployment so the domain points to the current instance correctly.
- Even with Cloudflare credentials configured, the current plugin only updates the `ns1.<zone>` A record by default; other records should still be checked manually.
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
- Reference for interactsh-server releases:
	- https://github.com/projectdiscovery/interactsh/releases
