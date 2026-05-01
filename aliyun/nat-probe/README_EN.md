# NAT Multi-EIP Traffic Probe

## Scene Description

This scenario creates one ECS instance, one NAT gateway, and multiple EIPs in Alibaba Cloud, then maps multiple public exits to a single probing host. It is suitable for traffic probing, honeypot ingress, multi-exit observation, and infrastructure validation with multiple public IPs.

After deployment, you get the full EIP list, the default SSH entry, per-EIP SSH commands, the ECS login password, and a NAT summary that can be used for further validation or automation.

## Prerequisites

- You need working Alibaba Cloud credentials with permissions to create ECS, VPC, vSwitch, NAT gateway, EIPs, and security groups.
- Confirm that your account has enough ECS, NAT, and EIP quota in the target region.
- The default region is `cn-beijing`, and the default instance type is `ecs.e-c1m2.large`; adjust them if capacity is limited.
- This scenario incurs NAT gateway and multiple EIP costs, so confirm your billing and budget expectations before deployment.

## Quick Start

```bash
redc pull aliyun/nat-probe
redc run aliyun/nat-probe
redc run aliyun/nat-probe -e eip_count=10
redc status [uuid]
redc stop [uuid]
```

The default deployment creates 5 EIPs. Override it with `-e eip_count=...` when you need more exits.

## Parameters

| Parameter | Required | Default | Example | Behavior Impact |
|-----------|----------|---------|---------|-----------------|
| `region` | No | `cn-beijing` | `cn-hangzhou` | Controls the deployment region and affects quota, cost, and instance availability. |
| `instance_name` | No | `nat-probe` | `nat-probe-prod` | Controls the ECS instance name shown in the console. |
| `instance_password` | No | Auto-generated | `StrongPass123!` | Controls the ECS login password; when left empty, it is generated automatically and returned in outputs. |
| `instance_type` | No | `ecs.e-c1m2.large` | `ecs.c6.large` | Controls the ECS size, affecting cost, capacity, and available compute resources. |
| `eip_count` | No | `5` | `10` | Controls how many EIPs are attached, directly affecting exit count, DNAT rules, and cost. |
| `eip_bandwidth` | No | `100` | `50` | Controls bandwidth per EIP and affects throughput and cost. |
| `eip_isp` | No | `BGP` | `BGP_PRO` | Controls the EIP line type and affects line quality and billing behavior. |

## Outputs

When deployment outputs drive your next step, focus on these fields first:

- `public_ip`: The default public entry point, which is the first EIP.
- `eip_addresses`: Full list of attached EIPs for validation and multi-exit use.
- `ssh_command`: Default SSH login command for the probing host.
- `ssh_commands`: Per-EIP SSH commands, useful for checking DNAT mapping behavior.
- `ecs_password` / `ssh_password`: ECS login password.
- `nat_gateway_id`: NAT gateway identifier for console-side inspection.
- `summary`: Deployment summary with EIP count, mappings, and the default entry point.

## FAQ

- If deployment fails, check these items first:
  1. Whether ECS, NAT, or EIP quota is sufficient in the selected region.
  2. Whether the selected instance type is sold out or unavailable.
  3. Whether the requested EIP count exceeds regional or account limits.
  4. Whether NAT gateway and multiple EIP billing constraints are blocking resource creation.
- If SSH through the second or third EIP feels "inconsistent," that is expected: every public entry still uses external port 22, but DNAT maps it to a different internal ECS port.

## Notes

- The ECS instance itself does not receive a direct public IP; all traffic is forwarded through the NAT gateway and EIPs.
- Security groups allow all TCP/UDP by default. Tighten them for production use.
- Alibaba Cloud security agent (aegis) is removed after deployment.

## Appendix

### Architecture

```text
                    ┌─────────────┐
    Internet ──────>│ NAT Gateway │
                    │             │
                    │  EIP-1 ─────┤──> SNAT + DNAT (EIP:22 → ECS:22)
                    │  EIP-2 ─────┤──> SNAT + DNAT (EIP:22 → ECS:122)
                    │  EIP-3 ─────┤──> SNAT + DNAT (EIP:22 → ECS:222)
                    │  EIP-N ─────┤──> SNAT + DNAT (EIP:22 → ECS:N*100+22)
                    └──────┬──────┘
                           │
                    ┌──────┴──────┐
                    │ ECS Instance│
                    │ (Private IP)│
                    │ Multi-port  │
                    │ sshd        │
                    │ tcpdump/nmap│
                    └─────────────┘
```

### DNAT Port Mapping Rules

| EIP | External Port | ECS Internal Port | Description |
|-----|--------------|-------------------|-------------|
| EIP[1] | 22 | 22 | Default SSH |
| EIP[2] | 22 | 122 | 2nd EIP |
| EIP[3] | 22 | 222 | 3rd EIP |
| EIP[N] | 22 | N×100+22 | Nth EIP |

The ECS `user_data` automatically configures sshd to listen on these internal ports.

### Traffic Probe Examples

```bash
# SSH via EIP[1] (default port 22)
ssh root@<EIP-1>

# SSH via EIP[2] (still external port 22, internally mapped to 122)
ssh root@<EIP-2>

# Check which ports sshd is listening on
ss -tlnp | grep sshd

# Monitor traffic from a specific EIP by filtering the internal port
tcpdump -i eth0 -nn port 122

# Check current egress IP (SNAT rotation)
curl -s ifconfig.me
```

### Design Notes and Limitations

- Alibaba Cloud DNAT cannot map multiple EIPs with full-port forwarding to the same ECS, so this template uses port-level mapping instead.
- A multi-ENI approach could make each EIP fully reachable, but it is constrained by ENI limits and is not suitable for a large EIP set.
