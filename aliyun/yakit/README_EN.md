# Aliyun Yakit Server Scenario

## Scene Description

This scene deploys a Yakit server host in the Aliyun Beijing region, downloads the `yak` binary automatically, and starts it as a systemd service. It is suitable for quickly bringing up a remote scanning or protocol analysis node.

After deployment, you get the public IP, instance password, Yakit listening port, and SSH command. You can connect to the server directly from a Yakit client or log in to inspect the service state.

## Prerequisites

- redc must already be configured with working Aliyun credentials.
- Your account must have enough balance and permission to create ECS instances in `cn-beijing`.
- This scene downloads the `yak` binary directly from Aliyun OSS and does not require a GitHub proxy.
- If clients need to reach the server from outside, make sure your network path allows access to the selected `yakit_port`.

## Quick Start

```bash
redc pull aliyun/yakit
redc run aliyun/yakit
redc status [uuid]
redc stop [uuid]
```

To override the listening port, instance name, or login password:

```bash
redc run aliyun/yakit \
   -e yakit_port=9999 \
   -e instance_name=yakit-server \
   -e instance_password='YourPassword123!'
```

## Parameters

| Parameter | Default | Description |
| --- | --- | --- |
| `instance_name` | `yakit-server` | Instance name. |
| `yakit_port` | `8087` | Yakit server listening port. |
| `instance_password` | auto-generated | Instance login password. If left empty, the template generates a random one. |

## Outputs

- `ecs_ip` / `public_ip`: Instance public IP address.
- `ecs_password` / `ssh_password`: Effective login password.
- `yakit_port`: Current service listening port.
- `ssh_user`: Default SSH username, currently `root`.
- `ssh_command`: Copy-ready SSH command.

## Notes

- The region is fixed to `cn-beijing`.
- The current instance type is fixed to `ecs.c7a.large`, with a 20 GB ESSD system disk. If that instance type is unavailable in the region, startup fails.
- Although the template adds dedicated rules for SSH and `yakit_port`, it also allows all inbound TCP and UDP traffic. Tighten access after deployment if the host is not meant to remain broadly exposed.
- The `yak` binary is fetched from Aliyun OSS. If that download fails, the server will not start correctly.
- Common failure causes are insufficient balance, Aliyun API network timeouts, capacity shortages in the current region, or a failed `yakit` systemd start. You can inspect it with `systemctl status yakit` after login.

## Appendix

- `yak` binary path: `/usr/local/bin/yak`
- systemd service file: `/etc/systemd/system/yakit.service`
- Current start command: `yak grpc --port <yakit_port>`
- Download URL: `https://yaklang.oss-cn-beijing.aliyuncs.com/yak/latest/yak_linux_amd64`
