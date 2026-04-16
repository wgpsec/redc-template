# NAT Multi-EIP Traffic Probe

Alibaba Cloud ECS + NAT Gateway + Multi Elastic IP traffic probe scenario.

## Architecture

```
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
                    │  sshd       │
                    │ tcpdump/nmap│
                    └─────────────┘
```

## Features

- **Multiple EIP Binding**: 5 EIPs by default (adjustable via `eip_count`), all bound to the NAT gateway
- **All EIPs Reachable**: Each EIP's port 22 is DNAT-mapped to a different internal ECS port (22, 122, 222...), SSH accessible through any EIP
- **SNAT Egress IP Pool**: All EIPs form an egress pool, outbound traffic rotates across EIPs
- **Traffic Source Identification**: Distinguish which EIP traffic originates from by the internal listening port
- **Pre-installed Tools**: tcpdump, nmap, net-tools and other probing tools

## DNAT Port Mapping Rules

| EIP | External Port | ECS Internal Port | Description |
|-----|--------------|-------------------|-------------|
| EIP[1] | 22 | 22 | Default SSH |
| EIP[2] | 22 | 122 | 2nd EIP |
| EIP[3] | 22 | 222 | 3rd EIP |
| EIP[N] | 22 | N×100+22 | Nth EIP |

The ECS user_data automatically configures sshd to listen on all these ports.

## Design Notes & Limitations

### Why can't multiple EIPs do full-port mapping to the same ECS?

Alibaba Cloud DNAT has two limitations:
1. `ip_protocol=any` + `port=any` (IP mapping mode) conflicts with SNAT rules
2. The same `internal_ip + internal_port` can only be mapped by one DNAT rule

Therefore it's impossible to have multiple EIPs all full-port forwarding to the same ECS. The current approach uses **port-level mapping**: each EIP's specific port (e.g., 22) maps to a different internal port on the ECS.

### Why not use multiple ENIs with direct EIP binding?

The multi-ENI approach allows each EIP to be naturally full-port reachable, but:
- ENI count is limited by instance type (small instances usually support only 2-3)
- Requires manual policy routing configuration inside the instance
- Not suitable for many EIPs (NAT gateway supports up to 100 EIPs)

## Usage

### Via redc

```bash
# Pull template
redc pull aliyun/nat-probe

# Deploy (default 5 EIPs)
redc run aliyun/nat-probe

# Deploy with 10 EIPs
redc run aliyun/nat-probe -var eip_count=10

# Check status
redc status

# Destroy
redc stop
```

### Standalone

```bash
cd aliyun/nat-probe

terraform init
terraform plan -var="eip_count=5"
terraform apply -auto-approve -var="eip_count=5"
terraform destroy -auto-approve
```

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `region` | `cn-beijing` | Alibaba Cloud region |
| `instance_name` | `nat-probe` | ECS instance name |
| `instance_password` | Auto-generated | ECS login password |
| `instance_type` | `ecs.e-c1m2.large` | ECS instance type (2C4G) |
| `eip_count` | `5` | Number of EIPs |
| `eip_bandwidth` | `100` | Bandwidth per EIP (Mbps) |
| `eip_isp` | `BGP` | EIP ISP (BGP/BGP_PRO) |

## Outputs

| Output | Description |
|--------|-------------|
| `eip_addresses` | List of all EIP addresses |
| `ssh_commands` | SSH commands for each EIP with internal port mapping |
| `ecs_password` | ECS login password |
| `nat_gateway_id` | NAT gateway ID |
| `summary` | Deployment summary |

## Traffic Probe Examples

```bash
# SSH via EIP[1] (default port 22)
ssh root@<EIP-1>

# SSH via EIP[2] (external port 22, internally routed to 122)
ssh root@<EIP-2>

# Check which ports sshd is listening on
ss -tlnp | grep sshd

# Monitor traffic from a specific EIP (filter by internal port)
tcpdump -i eth0 -nn port 122   # Traffic from EIP[2]

# Check current egress IP (SNAT rotation)
curl -s ifconfig.me
```

## Notes

1. The ECS instance has no public IP itself; all traffic goes through the NAT gateway
2. EIPs are pay-per-traffic (PayByTraffic); monitor traffic costs
3. Security groups allow all TCP/UDP by default — restrict as needed for production
4. Alibaba Cloud security agent (aegis) is removed after deployment
