# Huawei Cloud NPS

## Scene Description

This scene deploys an Ubuntu 18.04 x86_64 host in Huawei Cloud region `cn-north-4` (Beijing 4), installs NPS automatically, and exposes the web management interface through a public EIP. It also creates a dedicated VPC, subnet, security group, and EIP for the instance, making it suitable for quickly bringing up an NPS server for temporary validation or lab connectivity tests.

## Prerequisites

- You need valid Huawei Cloud credentials: `huaweicloud_access_key` and `huaweicloud_secret_key`.
- You must provide `github_proxy`, because the template downloads the NPS server package through `${github_proxy}/ehang-io/nps/...`.
- You must provide `base64_command`; it is base64-decoded and written to `/etc/nps/conf/nps.conf` as the actual NPS configuration file.
- `instance_password` can be left empty for auto-generation, or passed explicitly if you want a fixed root password.

## Quick Start

Pull the scene:

```bash
redc pull huaweicloud/nps
```

After preparing your NPS configuration file, encode it with base64 and start the scene:

```bash
redc run huaweicloud/nps \
  -e huaweicloud_access_key=YOUR_ACCESS_KEY \
  -e huaweicloud_secret_key=YOUR_SECRET_KEY \
  -e github_proxy=https://YOUR_GITHUB_PROXY \
  -e base64_command=BASE64_ENCODED_NPS_CONF
```

If you want to pin the instance login password, pass it explicitly as well:

```bash
redc run huaweicloud/nps \
  -e huaweicloud_access_key=YOUR_ACCESS_KEY \
  -e huaweicloud_secret_key=YOUR_SECRET_KEY \
  -e github_proxy=https://YOUR_GITHUB_PROXY \
  -e base64_command=BASE64_ENCODED_NPS_CONF \
  -e instance_password='YourPassword123!'
```

Check the running status:

```bash
redc status [uuid]
```

Stop the scene:

```bash
redc stop [uuid]
```

## Parameters

| Parameter | Default | Description |
| --- | --- | --- |
| `huaweicloud_access_key` | required | Huawei Cloud Access Key. |
| `huaweicloud_secret_key` | required | Huawei Cloud Secret Key. |
| `base64_command` | required | Base64 content of the NPS configuration file. It is written to `/etc/nps/conf/nps.conf` during startup. |
| `github_proxy` | required | Download prefix for the NPS release archive, such as a reachable GitHub Release proxy. |
| `instance_password` | auto-generated | Root password for the instance. If left empty, the template generates a random password. |

## Outputs

- `nps_ip`: Public IP address of the NPS server.
- `nps_address_link`: Template output for the default web management address. With the sample config in this repository it is typically `http://PUBLIC_IP:8080`, but if you pass a custom `nps.conf`, the live value follows your `web_port`, `web_open_ssl`, and related settings.
- `nps_username`: Template output for the default web username. With the sample config in this repository it is `redone`, but if you customize `nps.conf`, the live value follows `web_username`.
- `nps_password`: Template output for the default web password. With the sample config in this repository it is `1!2A3d4v5s6e`, but if you customize `nps.conf`, the live value follows `web_password`.
- `ecs_ip` / `public_ip`: Public IP address of the instance.
- `ecs_password` / `ssh_password`: Root password for the instance.
- `ssh_user`: Default SSH username, currently `root`.
- `ssh_command`: Copy-ready SSH command.

## Notes

- The region is fixed to `cn-north-4`, the availability zone is fixed to `cn-north-4a`, and the compute flavor is auto-selected from 1 vCPU / 1GB options.
- The security group allows all IPv4 ingress and egress traffic. If the instance will stay online beyond short-lived testing, tighten exposure after deployment.
- The user data installs basic tools such as tmux, wget, and unzip, then downloads and installs NPS, decodes `base64_command` into `/etc/nps/conf/nps.conf`, and starts the service.
- The sample `nps.conf` in this repository uses `redone / 1!2A3d4v5s6e / 8080` as the web management defaults. If you pass a custom config through `base64_command`, the live runtime values follow your `nps.conf` instead.
- Common failure causes are invalid Huawei Cloud credentials, insufficient balance or quota, an unreachable `github_proxy`, or an invalid `base64_command` payload.
