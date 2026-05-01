# NPS Internal Tunneling Scenario

## Scene Description

This scenario deploys an x86_64 host with a pre-installed NPS server in Tencent Cloud ap-beijing. It is suitable for quickly setting up internal tunneling, port forwarding, and a basic proxy entry point.

After deployment, you get the NPS web console address, default web credentials, the instance public IP, and SSH login information. By default, the template uses the bundled [nps.conf](nps.conf); if needed, you can also inject a base64-encoded custom configuration at startup.

## Prerequisites

- You need working Tencent Cloud credentials and permissions to create CVM instances, security groups, and related resources.
- This template is fixed to the ap-beijing region and an S6 2C2G instance family, so confirm both account balance and regional capacity in advance.
- If you are not using redc-managed credentials, fill in `tencentcloud_secret_id` and `tencentcloud_secret_key` in `terraform.tfvars` yourself.
- If you want to override the default `nps.conf`, prepare the config file first and convert it to base64 text before startup.

## Quick Start

```bash
redc pull tencent/nps
redc run tencent/nps
redc status [uuid]
redc stop [uuid]
```

If you want to load a custom `nps.conf` at startup, pass it through the generic variable entry as `base64_command`, for example:

```bash
redc run tencent/nps -e base64_command="$(base64 < nps.conf | tr -d '\n')"
```

## Parameters

| Parameter | Required | Default | Example | Behavior Impact |
|-----------|----------|---------|---------|-----------------|
| `instance_name` | No | `nps` | `nps-prod` | Controls the instance name shown in Tencent Cloud. |
| `instance_password` | No | Auto-generated | `StrongPass123!` | Controls the SSH login password; when left empty, it is generated automatically and returned in outputs. |
| `base64_command` | No | Bundled `nps.conf` | `$(base64 < nps.conf | tr -d '\n')` | Replaces the default `nps.conf` at startup and changes the bridge, web, and other NPS runtime behaviors. |
| `github_proxy` | No | `https://ghfast.top/github.com` | `https://ghproxy.link/github.com` | Controls the accelerated download address for the NPS archive during bootstrap. |

## Outputs

When deployment outputs drive your next step, focus on these fields first:

- `nps_address_link`: NPS web console URL, defaulting to port `8080`.
- `nps_username` / `nps_password`: Built-in default web console credentials; if you override the web configuration through a custom `nps.conf`, trust the injected config instead.
- `public_ip` / `nps_ip` / `ecs_ip`: Public IP of the instance, useful for client access, firewall checks, and troubleshooting.
- `ssh_command`: Ready-to-run SSH login command.
- `ssh_password` / `ecs_password`: SSH login password for the instance.

## FAQ

- If NPS does not start after injecting a custom config, first verify that the base64 payload is complete and decodes into a valid `nps.conf`.
- If startup fails, check these items first:
	1. Whether the Tencent Cloud account balance is sufficient.
	2. Whether the Tencent Cloud API connection timed out.
	3. Whether the ap-beijing instance type is sold out or unavailable.
	4. Whether the GitHub proxy address is reachable and the archive download succeeded.

## Notes

- The default configuration file is already included with the template. Refer to [nps.conf](nps.conf) directly, and use `-e base64_command=...` only when you want to override it.
- The default web console port is `8080`; restrict access in the security group if needed after deployment.

## Appendix

- For standalone Terraform usage, you can fill Tencent Cloud credentials in `terraform.tfvars`, for example:

```hcl
tencentcloud_secret_id  = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
tencentcloud_secret_key = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
github_proxy            = "https://ghfast.top/github.com"
```

- If needed, replace the NPS archive source with another release URL:
	- https://github.com/ehang-io/nps/releases
