---
name: Cloud Cost Optimization
description: Strategies for minimizing cloud infrastructure costs in red team deployments. Use this skill whenever the user asks about pricing, budgets, cost estimates, instance sizing, spot instances, or resource cleanup. Also apply when the user is choosing instance types, discussing how long to keep infrastructure running, asking about billing alerts, or planning a deployment where cost is a concern — even if they don't explicitly mention "cost" or "budget". Proactively reference this skill when generating templates to suggest cost-saving alternatives.
tags: cost, optimization, pricing, budget, spot, instance-type, billing, savings, cleanup
---

# Cloud Cost Optimization for Red Team Infrastructure

Cloud costs in red team operations are uniquely spiky — you might spin up 50 instances for a week-long engagement, then nothing for a month. This pattern makes it easy to waste money through oversized instances, forgotten infrastructure, or missed opportunities for spot pricing. The strategies here are specifically tuned for the "burst and teardown" pattern typical of red team work.

## Instance Right-Sizing

Most red team tools (C2 frameworks, scanners, proxy servers) are surprisingly lightweight. Overprovisioning is the most common cost mistake.

**Practical baselines:**
- **Minimum viable**: 2 vCPU + 4 GB RAM handles most single-tool deployments (Cobalt Strike, Sliver, scanning)
- **Comfortable**: 4 vCPU + 8 GB RAM for multi-tool setups or heavy scanning
- **Overkill warning**: If you're deploying `m5.2xlarge` or equivalent for a single C2 server, you're paying 4x more than necessary

| Use Case | AWS | Azure | GCP | Monthly Cost (approx.) |
|----------|-----|-------|-----|----------------------|
| Light (C2, proxy) | `t3.small` | `B2s` | `e2-small` | $15-20 |
| Standard (multi-tool) | `t3.medium` | `B2ms` | `e2-medium` | $30-40 |
| Heavy (scanning cluster) | `t3.xlarge` | `B4ms` | `e2-standard-4` | $60-80 |

**ARM instances** (AWS `t4g`, Azure `Dpsv5`) are ~20% cheaper than x86 equivalents. Most tools work fine on ARM, but some (like certain compiled exploit frameworks) require x86. Test before committing.

**How to check if you're oversized:** SSH into running instances and check `top` or `htop`. If CPU stays under 30% and memory under 50% consistently, downsize one tier.

## Time-Based Savings

Infrastructure that sits idle is pure waste. Red team engagements have natural downtime (nights, weekends, waiting for client responses) where instances can be stopped.

- **Auto-shutdown**: Use RedC's scheduled task feature to stop instances outside working hours. A 12-hours-on/12-hours-off schedule cuts compute costs by 50%
- **Engagement-scoped lifecycle**: Set a hard destruction date when creating infrastructure. If the engagement is 2 weeks, schedule `stop_case` for day 15. You will forget otherwise
- **Off-peak spot pricing**: Spot/preemptible instance prices fluctuate by time of day. US regions are cheapest during Asian business hours and vice versa

**Example — RedC scheduled auto-destroy:**
Use `list_cases` to find the case ID, then schedule destruction:
```
Schedule: stop_case("my-engagement") at 2024-03-15T00:00:00Z
```

## Spot and Preemptible Instances

Spot instances offer 60-90% savings over on-demand pricing, but they can be interrupted with 2 minutes' notice.

**Good candidates for spot:**
- Scanning infrastructure (nmap, masscan) — easily restartable
- Data processing and exfiltration staging — stateless by nature
- Short-lived redirectors — replaceable if terminated

**Bad candidates for spot:**
- Long-running C2 servers — an interruption drops all active sessions
- Persistent implant listeners — downtime means missed callbacks
- Infrastructure that takes >30 minutes to configure — the setup cost exceeds savings if frequently interrupted

**AWS spot tip:** Set `instance_interruption_behavior = "stop"` instead of `"terminate"` so the instance pauses rather than being destroyed. You keep your data and can restart when capacity returns.

## Storage Optimization

Storage costs are small per-unit but add up across many instances and forgotten snapshots.

- **Right-size disks**: 18-20 GB is sufficient for most red team scenarios. The default 30 GB in many AMIs wastes 40% of the disk cost
- **Use gp3 over gp2** (AWS): gp3 is 20% cheaper at baseline and lets you configure IOPS independently. There's no reason to use gp2 for new deployments
- **Clean up snapshots**: Every `terraform destroy` might leave behind EBS snapshots. Check and delete them monthly
- **Ephemeral storage**: For temporary data (scan results, staging), use instance store volumes (free) instead of EBS

## Network Cost Reduction

Data transfer is the hidden cost multiplier that catches people off guard. AWS charges $0.09/GB for data leaving a region.

- **Same-region deployments**: Keep all instances in one region when possible. Cross-region data transfer is expensive ($0.02/GB between regions)
- **Minimize egress**: If exfiltrating large amounts of data, consider compressing it first. A 10x compression ratio means 10x less transfer cost
- **VPC endpoints** (AWS): Route S3 and other AWS service traffic through VPC endpoints instead of NAT gateways. NAT gateway charges $0.045/GB processed; VPC endpoints are free for S3
- **Avoid unnecessary cross-AZ traffic**: Each AZ-to-AZ hop within a region costs $0.01/GB in both directions

## Cost Monitoring

Proactive monitoring prevents surprise bills.

- Use RedC's `get_balances` tool to check all cloud account credits in one place
- Use `get_predicted_monthly_cost` before deploying to estimate what you'll spend
- Set billing alerts at 50%, 80%, and 100% of your budget threshold on every cloud account
- Review monthly bills for line items you don't recognize — orphaned elastic IPs ($3.65/month each), unused EBS volumes, and idle load balancers are common culprits
