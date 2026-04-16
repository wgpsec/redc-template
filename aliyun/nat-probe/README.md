# NAT 多 EIP 流量探针

阿里云 ECS + NAT 网关 + 多弹性公网 IP 流量探针场景

## 架构

```
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
                    │ tcpdump/nmap│
                    └─────────────┘
```

## 特性

- **多 EIP 绑定**: 默认 5 个 EIP（通过 `eip_count` 变量调整），全部绑定到 NAT 网关
- **所有 EIP 可达**: 每个 EIP 的 22 端口 DNAT 到 ECS 不同内部端口（22, 122, 222...），通过任一 EIP 均可 SSH
- **SNAT 出口 IP 池**: 所有 EIP 组成出口 IP 池，出网流量轮换使用不同 EIP
- **流量来源识别**: 通过 ECS 内部监听端口号区分流量来自哪个 EIP
- **预装工具**: tcpdump、nmap、net-tools 等探测工具

## DNAT 端口映射规则

| EIP | 外部端口 | ECS 内部端口 | 说明 |
|-----|---------|-------------|------|
| EIP[1] | 22 | 22 | 默认 SSH |
| EIP[2] | 22 | 122 | 第 2 个 EIP |
| EIP[3] | 22 | 222 | 第 3 个 EIP |
| EIP[N] | 22 | N×100+22 | 第 N 个 EIP |

ECS 的 user_data 自动配置 sshd 监听所有这些端口。

## 设计说明与限制

### 为什么不能多 EIP 全端口映射到同一台 ECS？

阿里云 DNAT 有两个限制：
1. `ip_protocol=any` + `port=any`（IP 映射模式）会与 SNAT 规则冲突
2. 同一个 `internal_ip + internal_port` 只能被一条 DNAT 规则映射

因此无法让多个 EIP 都全端口转发到同一台 ECS。当前方案采用 **端口级映射**：每个 EIP 的特定端口（如 22）映射到 ECS 的不同内部端口。

### 为什么不用多网卡（ENI）直接绑 EIP？

多 ENI 方案可以让每个 EIP 天然全端口可达，但：
- ENI 数量受实例规格限制（小规格通常只支持 2-3 个）
- 需要在实例内手动配置策略路由
- 不适合大量 EIP 的场景（NAT 网关支持最多 100 个 EIP）

### 未来规划：IaC Agent + 蜜罐 Agent

当前模板适合作为 **自动化蜜罐部署** 的基础设施层：

```
用户自然语言指令
    │
    ▼
┌──────────────┐     ┌──────────────────┐
│  redc IaC    │────>│  Terraform 模板   │
│  Agent       │     │  (NAT+EIP+DNAT)  │
│  自动改 TF   │     │  terraform apply  │
└──────────────┘     └────────┬─────────┘
                              │
                     ┌────────▼─────────┐
                     │  ECS 蜜罐 Agent   │
                     │  自动识别新端口    │
                     │  启动监听服务      │
                     └──────────────────┘
```

**工作流设想**：
1. 用户说 `"给蜜罐加 3 个新 EIP，监听 80 和 443"`
2. redc IaC Agent 自动修改 TF 模板（增 eip_count、添加 DNAT 规则）
3. 执行 `terraform apply`
4. ECS 上的蜜罐 Agent 检测到新端口映射，自动启动对应监听服务
5. 用户无需手动碰任何 DNAT 规则

## 使用方式

### 通过 redc 引擎

```bash
# 拉取模板
redc pull aliyun/nat-probe

# 部署 (默认 5 个 EIP)
redc run aliyun/nat-probe

# 部署 10 个 EIP
redc run aliyun/nat-probe -var eip_count=10

# 查看状态
redc status

# 销毁
redc stop
```

### 独立使用

```bash
cd aliyun/nat-probe

# 初始化
terraform init

# 预览
terraform plan -var="eip_count=5"

# 部署
terraform apply -auto-approve -var="eip_count=5"

# 销毁
terraform destroy -auto-approve
```

## 变量说明

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `region` | `cn-beijing` | 阿里云区域 |
| `instance_name` | `nat-probe` | ECS 实例名称 |
| `instance_password` | 自动生成 | ECS 登录密码 |
| `instance_type` | `ecs.e-c1m2.large` | ECS 实例规格 (2C4G) |
| `eip_count` | `5` | EIP 数量 |
| `eip_bandwidth` | `100` | 每个 EIP 带宽 (Mbps) |
| `eip_isp` | `BGP` | EIP 线路 (BGP/BGP_PRO) |

## 输出

| 输出 | 说明 |
|------|------|
| `eip_addresses` | 所有 EIP 地址列表 |
| `ssh_commands` | 每个 EIP 的 SSH 命令及对应内部端口 |
| `ecs_password` | ECS 登录密码 |
| `nat_gateway_id` | NAT 网关 ID |
| `summary` | 部署摘要 |

## 流量探针使用示例

```bash
# 通过 EIP[1] SSH 登录 (默认端口 22)
ssh root@<EIP-1>

# 通过 EIP[2] SSH 登录 (同样用外部 22 端口，内部转到 122)
ssh root@<EIP-2>

# 登录后查看各端口连接，识别流量来源 EIP
ss -tlnp | grep sshd

# 监听某个 EIP 的流量 (通过内部端口过滤)
tcpdump -i eth0 -nn port 122   # 来自 EIP[2] 的流量

# 在多个 EIP 上同时监听
tmux new-session -d -s probe
tmux send-keys "tcpdump -i eth0 -nn 'dst port 122'" Enter

# 查看当前出口 IP (SNAT 轮换)
curl -s ifconfig.me
```

## 注意事项

1. ECS 实例本身不分配公网 IP，所有出入网流量均通过 NAT 网关
2. EIP 按量付费 (PayByTraffic)，注意流量成本
3. 安全组默认放行所有 TCP/UDP，生产环境请按需收紧
4. 部署后卸载了阿里云云盾 (aegis)
