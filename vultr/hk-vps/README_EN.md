# Vultr VPS Scenario

## Scene Description

This scene deploys a lightweight VPS on Vultr and uses `init.sh` as the startup script for basic initialization. It is suitable for quickly bringing up a general-purpose overseas host that you can log into directly.

Although the folder name is `hk-vps`, the current template actually defaults to the `sgp` region (Singapore), not Hong Kong.

## Prerequisites

- redc must already be configured with a working Vultr API key, or `VULTR_API_KEY` must be available in the environment.
- Your account must have enough balance and permission to create instances in the target region.
- `init.sh` is injected automatically through a Vultr startup script. If you modify the template, check that script together with the Terraform changes.

## Quick Start

```bash
redc pull vultr/hk-vps
redc run vultr/hk-vps
redc status [uuid]
redc stop [uuid]
```

To override the region, plan, or OS ID:

```bash
redc run vultr/hk-vps \
    -e region=sgp \
    -e plan=vc2-1c-2gb \
    -e os_id=477
```

## Parameters

| Parameter | Default | Description |
| --- | --- | --- |
| `region` | `sgp` | Vultr region code. The current default is Singapore. |
| `plan` | `vc2-1c-2gb` | Instance plan. |
| `os_id` | `477` | Operating system ID. The current default maps to Ubuntu 22.04 x64. |

## Outputs

- `vps_ip` / `main_ip` / `public_ip`: Instance public IP address.
- `password` / `ssh_password`: Default root password returned by Vultr on first creation.
- `ssh_user`: Default SSH username, currently `root`.
- `ssh_command`: Copy-ready SSH command.
- `vps_os`, `vps_ram`, `vps_disk`, `vps_allowed_bandwidth`, `vps_hostname`: Instance metadata for quick capacity verification.

## Notes

- The provider reads credentials directly from `VULTR_API_KEY`, so there is no need to go back to the old `deploy.sh`-style API key injection.
- The current template fixes both `label` and `hostname` to `tf-1`; repeated runs are mainly distinguished by Vultr resource IDs.
- The template disables IPv6, backups, and DDoS protection.
- `ssh_password` depends on Vultr returning `default_password`; if you later switch to SSH-key-based login, that output may no longer be meaningful.
- Common failure causes are an invalid API key, Vultr API network timeouts, or lack of capacity for the selected region and plan.

## Appendix

- `init.sh` is injected automatically through the `vultr_startup_script` resource.
- If you need to adjust initialization behavior, check [init.sh](init.sh) in the same directory.
