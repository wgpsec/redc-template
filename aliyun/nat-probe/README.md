# NAT 多 EIP 流量探针

## 场景说明

该场景会在阿里云创建一台 ECS、一个 NAT 网关以及多枚 EIP，把多个公网出口统一映射到同一台探针主机上，适合做流量探测、蜜罐入口、多出口观察和带多 EIP 的基础设施验证。

部署完成后，你会得到所有 EIP 列表、默认 SSH 入口、每个 EIP 对应的 SSH 命令、ECS 登录密码以及 NAT 网关摘要信息，便于继续做流量监听、映射验证和后续自动化接入。

## 前置条件

- 需要可用的阿里云凭据，并确保账号具有创建 ECS、VPC、交换机、NAT 网关、EIP 和安全组的权限。
- 需要确认账号在目标区域有足够的实例、EIP 和 NAT 相关配额。
- 该场景默认区域为 `cn-beijing`，默认实例规格为 `ecs.e-c1m2.large`，可根据容量情况自行调整。
- 场景会产生 NAT 网关和多枚 EIP 费用，使用前需确认预算和按量付费策略。

## 快速使用

```bash
redc pull aliyun/nat-probe
redc run aliyun/nat-probe
redc run aliyun/nat-probe -e eip_count=10
redc status [uuid]
redc stop [uuid]
```

默认部署 5 个 EIP；如果需要更多出口，可通过 `-e eip_count=...` 覆盖默认值。

## 参数说明

| 参数名 | 是否必填 | 默认值 | 示例 | 行为影响 |
|--------|----------|--------|------|----------|
| `region` | 否 | `cn-beijing` | `cn-hangzhou` | 控制部署区域，影响可用配额、EIP 成本和实例库存。 |
| `instance_name` | 否 | `nat-probe` | `nat-probe-prod` | 控制 ECS 实例名称，便于在控制台中区分部署。 |
| `instance_password` | 否 | 自动生成 | `StrongPass123!` | 控制 ECS 登录密码；留空时自动生成，并通过输出返回。 |
| `instance_type` | 否 | `ecs.e-c1m2.large` | `ecs.c6.large` | 控制 ECS 规格，影响成本、可用性和可挂载能力。 |
| `eip_count` | 否 | `5` | `10` | 控制绑定的 EIP 数量，直接影响出口数量、DNAT 规则数量和整体成本。 |
| `eip_bandwidth` | 否 | `100` | `50` | 控制每个 EIP 的带宽上限，影响出口能力和成本。 |
| `eip_isp` | 否 | `BGP` | `BGP_PRO` | 控制 EIP 线路类型，影响线路质量和计费策略。 |

## 输出说明

当部署输出会驱动用户下一步操作时，建议优先关注以下字段：

- `public_ip`：默认公网入口，也就是第一个 EIP。
- `eip_addresses`：全部 EIP 列表，可用于批量验证多出口和映射结果。
- `ssh_command`：默认 SSH 登录命令，可直接进入探针主机。
- `ssh_commands`：按 EIP 列出的 SSH 命令，便于逐个验证 DNAT 映射关系。
- `ecs_password` / `ssh_password`：ECS 登录密码。
- `nat_gateway_id`：NAT 网关 ID，便于在控制台继续核查规则。
- `summary`：部署摘要，快速汇总了 EIP 数量、映射关系和默认入口。

## 常见问题

- 如果部署失败，优先检查以下几项：
  1. 阿里云账号在当前区域的 ECS、EIP 或 NAT 配额是否充足。
  2. 当前实例规格是否售罄或下架。
  3. EIP 数量设置是否超过当前账号或区域限制。
  4. NAT 网关和多 EIP 的费用策略是否导致创建失败或被策略拦截。
- 如果通过第二个或第三个 EIP SSH 登录时感觉“端口不一致”，这是场景设计使然：所有外部入口都使用 22 端口，但会 DNAT 到 ECS 内部不同端口。

## 注意事项

- ECS 实例本身不直接分配公网 IP，所有出入流量都通过 NAT 网关和 EIP 转发。
- 安全组默认放行所有 TCP/UDP，生产环境请按需收紧。
- 部署后会卸载阿里云云盾（aegis）。

## 附录

### 架构

```text
              ┌─────────────┐
    Internet ──────>│  NAT 网关    │
              │             │
              │  EIP-1 ─────┤──> SNAT + DNAT (EIP:22 → ECS:22)
              │  EIP-2 ─────┤──> SNAT + DNAT (EIP:22 → ECS:122)
              │  EIP-3 ─────┤──> SNAT + DNAT (EIP:22 → ECS:222)
              │  EIP-N ─────┤──> SNAT + DNAT (EIP:22 → ECS:N*100+22)
              └──────┬──────┘
                  │
              ┌──────┴──────┐
              │   ECS 实例   │
              │  (内网 IP)   │
              │ 多端口 sshd  │
              │ tcpdump/nmap │
              └─────────────┘
```

### DNAT 端口映射规则

| EIP | 外部端口 | ECS 内部端口 | 说明 |
|-----|---------|-------------|------|
| EIP[1] | 22 | 22 | 默认 SSH |
| EIP[2] | 22 | 122 | 第 2 个 EIP |
| EIP[3] | 22 | 222 | 第 3 个 EIP |
| EIP[N] | 22 | N×100+22 | 第 N 个 EIP |

ECS 的 `user_data` 会自动配置 sshd 监听这些内部端口。

### 流量探针使用示例

```bash
# 通过 EIP[1] SSH 登录 (默认端口 22)
ssh root@<EIP-1>

# 通过 EIP[2] SSH 登录 (外部仍是 22，内部转到 122)
ssh root@<EIP-2>

# 登录后查看各端口连接，识别流量来源 EIP
ss -tlnp | grep sshd

# 监听某个 EIP 的流量 (通过内部端口过滤)
tcpdump -i eth0 -nn port 122

# 查看当前出口 IP (SNAT 轮换)
curl -s ifconfig.me
```

### 设计说明与限制

- 阿里云 DNAT 不支持把多个 EIP 的全端口都映射到同一台 ECS，因此这里采用端口级映射。
- 多 ENI 直绑 EIP 的方式虽然更直接，但受网卡数量和实例规格限制，不适合大量 EIP 的场景。
