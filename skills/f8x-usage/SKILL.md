---
name: f8x-usage
description: Guide for using f8x, the red/blue team environment automation deployment tool. Use this skill whenever the user asks about installing security tools on a VPS, deploying pentest/red-team/blue-team environments, using f8x commands or flags, querying available tools via catalog, or automating tool installation through MCP/AI Agent integration with RedC. Also trigger when user mentions tool names like nuclei, httpx, nmap, subfinder, sqlmap, metasploit, CobaltStrike, Sliver, or any security tooling deployment on Linux servers.
---

# f8x 工具部署指南

f8x 是红蓝队环境自动化部署工具，支持在 Linux VPS 上一键安装 160+ 安全、开发和运维工具。支持 x86_64 和 aarch64 架构，自动检测系统环境。

项目地址: `https://github.com/ffffffff0x/f8x`

## 安装 f8x

```bash
# 方式 1: CDN (推荐)
wget -O f8x https://f8x.io/f8x && sudo bash f8x

# 方式 2: GitHub
curl -sSL https://raw.githubusercontent.com/ffffffff0x/f8x/main/f8x -o /tmp/f8x && sudo bash /tmp/f8x

# 在 redc 管理的 VPS 上，软件商店会自动部署 f8x
```

## CLI 参考

### 单工具管理 (AI Agent 友好接口)

这组命令是 AI Agent 与 f8x 交互的主要方式，其中 `--list-tools`、`--search`、`--list-installed` 无需 root 权限。

```bash
f8x -install <tool_name>    # 按名称安装单个工具 (如: f8x -install nuclei)
f8x --list-tools             # 输出所有可用工具 (JSON 格式, 约 160 个)
f8x --list-tools table       # 表格格式输出
f8x --search <keyword>       # 模糊搜索工具 (如: f8x --search scanner)
f8x --list-installed         # 查看已安装的工具 (读取 /opt/.f8x/installed.json)
```

`-install` 安装成功后会自动记录到 `/opt/.f8x/installed.json`，包含工具名、安装时间、安装方式和 f8x 版本。

### 批量安装 (按场景)

| Flag | 说明 | 典型工具 |
|------|------|----------|
| `-b` | 基础环境 | gcc, make, git, curl, vim, jq, unzip, telnet, SSH 优化, BBR |
| `-p` | 代理环境 | DNS 配置 + Proxychains-ng |
| `-d` | 开发环境 | Python3, pip3, Go, Docker, Docker-Compose, SDKMAN |
| `-ka` | 侦查套件 (Type A) | nmap, masscan, httpx, subfinder, ffuf, dirsearch, katana, fscan 等 30+ 工具 |
| `-kb` | 漏洞利用套件 (Type B) | Nuclei, sqlmap, Metasploit, xray, WPScan 等 |
| `-kc` | 后渗透套件 (Type C) | impacket, Responder, CrackMapExec, mitmproxy 等 |
| `-kd` | 密码/杂项 (Type D) | hashcat, jadx, ncat, mapcidr, dnsx 等 |
| `-ke` | 补充/字典 (Type E) | SecLists, hakrawler, subjs, assetfinder |
| `-k` | 完整渗透套件 | -ka + -kb + -kc + -kd + -ke 合并 |
| `-s` | 蓝队工具 | Fail2Ban, chkrootkit, rkhunter, shellpub |
| `-f` | 趣味/实用工具 | AdGuard, fzf, lux, ttyd, duf, yq |
| `-cloud` | 云工具 | Terraform, redc, Serverless, k8spider, kubectl, tccli |
| `-ad` | AD 域攻击 | impacket, Certipy, ligolo-ng 等 |
| `-arsenal` | 多平台二进制集 | 下载 fscan/gogo/spray/cdk/chisel/mimikatz 等的 linux_amd64/arm64/windows 版本到 /pentest/arsenal/ |
| `-all` | 全量部署 | 安装上述所有内容 |

### 单独安装开发组件

| Flag | 说明 |
|------|------|
| `-docker` / `-docker-cn` | Docker (国内镜像版) |
| `-go` | Go 语言 |
| `-nn` | Node.js + npm |
| `-py3` / `-py37` ~ `-py310` | Python 3 (可指定版本) |
| `-ruby` / `-rust` / `-lua` / `-perl` | 其他语言 |
| `-openjdk` / `-oraclejdk` | JDK |
| `-code` | code-server (浏览器版 VS Code) |
| `-chromium` | Chromium 无头浏览器 |
| `-pyenv` / `-jenv` | 版本管理器 |

### 单独安装安全工具

| Flag | 说明 |
|------|------|
| `-cs` / `-cs45` | CobaltStrike 4.3/4.5 |
| `-sliver` / `-sliver-client` | Sliver C2 服务端/客户端 |
| `-msf` | Metasploit |
| `-mythic` | Mythic C2 |
| `-frp` / `-nps` / `-chisel` / `-iox` | 隧道/代理工具 |
| `-rg` | RedGuard C2 前置流量控制 |
| `-awvs` / `-awvs14` / `-awvs15` | AWVS 漏扫 |
| `-arl` | ARL 资产侦查灯塔 (Docker, ~872MB) |
| `-yakit` | Yakit 安全平台 |
| `-wpscan` | WordPress 扫描 |

### 蓝队工具

| Flag | 说明 |
|------|------|
| `-binwalk` | Binwalk 固件分析 |
| `-clamav` | ClamAV 病毒扫描 |
| `-vol` / `-vol3` | Volatility 内存取证 |
| `-suricata` | Suricata IDS/IPS |
| `-lt` | LogonTracer Windows 登录事件分析 |

### 靶场环境 (需要 Docker)

| Flag | 说明 | 磁盘占用 |
|------|------|----------|
| `-vulhub` | VulHub 漏洞复现环境 | ~210MB |
| `-vulfocus` | VulFocus 漏洞靶场平台 | ~1.04GB |
| `-metarget` | Metarget 云原生靶场 | - |
| `-TerraformGoat` | TerraformGoat 云漏洞环境 | - |

### 系统管理

| Flag | 说明 |
|------|------|
| `-info` | 查看系统信息 |
| `-optimize` | 优化系统性能 |
| `-swap` | 配置 swap 分区 |
| `-clear` | 清理系统使用痕迹 |
| `-remove` | 卸载云主机监控 |
| `-rmlock` | 解除包管理器锁 |
| `-update` | 更新 f8x 自身 |
| `-upgrade` | 升级已安装的渗透工具 |

## 伴生脚本

除主脚本外，f8x 还提供两个专用脚本:

- **f8x-ctf** — CTF 比赛环境部署 (Web/Misc/Crypto/Pwn/Iot 方向)
- **f8x-dev** — 中间件/数据库部署 (Apache, Nginx, Tomcat, MySQL, PostgreSQL, Redis, PHP 等)

## 工具分类体系 (10 类)

| 分类 ID | 名称 | 说明 | 代表工具 |
|---------|------|------|----------|
| `basic` | 基础环境 | 编译器、系统工具、网络优化 | gcc, make, git, BBR |
| `development` | 开发环境 | 编程语言和容器 | Docker, Go, Python, Node.js, Rust |
| `pentest-recon` | 渗透侦查 | 资产发现与信息收集 | nmap, masscan, httpx, subfinder, ffuf, katana |
| `pentest-exploit` | 漏洞利用 | 扫描与漏洞利用 | Nuclei, sqlmap, Metasploit, xray |
| `pentest-post` | 后渗透 | 横向移动与权限维持 | impacket, hashcat, CrackMapExec, Responder |
| `blue-team` | 蓝队防御 | 主机安全与取证 | Binwalk, ClamAV, Volatility, Suricata |
| `red-infra` | 红队基础设施 | C2 框架与隧道 | CobaltStrike, Sliver, frp, nps, RedGuard |
| `vuln-env` | 靶场环境 | 漏洞复现与训练 | VulHub, VulFocus, TerraformGoat |
| `misc` | 杂项工具 | 面板、终端增强等 | zsh, fzf, 1Panel, AdGuard |
| `system` | 系统操作 | 更新、清理、优化 | swap 管理, 监控卸载, 日志清理 |

## 预设组合 (Presets)

f8x 的 catalog 中定义了 6 个预设组合，方便快速部署常见场景:

| 预设 ID | 名称 | 包含的 flags |
|---------|------|-------------|
| `pentest-full` | 完整渗透环境 | `-b -d -k` |
| `dev-env` | 开发环境 | `-b -d` |
| `blue-team` | 蓝队防御环境 | `-b -s` |
| `c2-setup` | C2 基础设施 | `-b -d` + 单独安装 C2 |
| `basic-all` | 基础环境 | `-b` |
| `recon-light` | 轻量侦查 | `-b -ka` |

## 工具依赖级别

每个工具有一个 `deps` 级别，决定安装前需要什么环境:

| deps | 含义 | 前置条件 |
|------|------|----------|
| 0 | 仅需基础环境 | wget 即可 (下载二进制) |
| 1 | 需要 Python | 先执行 `-d` 或 `-py3` |
| 2 | 需要 Go | 先执行 `-d` 或 `-go` |
| 3 | 需要 Python + Go | 先安装两者 |

## catalog.json — 结构化工具目录

f8x 维护一个机器可读的工具目录 `catalog.json` (部署在 `f8x.wgpsec.org`)，供外部系统 (如 RedC、AI Agent) 消费。结构:

```json
{
  "version": "1.9.1",
  "catalog_version": 4,
  "modules": [...],     // ~90 个 flag 对应的模块
  "tools": [...],       // ~160 个单独工具 (含 name, description, category, deps, url)
  "categories": [...],  // 10 个分类及工具计数
  "presets": [...]       // 6 个预设组合
}
```

`--list-tools` 的 JSON 输出即来源于此数据。

## 与 redc 配合使用

### 典型流程
1. 通过 redc 模板开启 VPS 场景 (userdata 自动安装核心依赖)
2. SSH 连接到 VPS
3. 按需通过软件商店 UI 或 `f8x -install` 加装额外工具

### MCP 工具 (AI Agent 可用)

在 RedC 平台中，AI Agent 可通过以下 MCP 工具操作 f8x:

| MCP 工具 | 参数 | 说明 |
|----------|------|------|
| `get_f8x_catalog` | `category?`, `keyword?` | 查询可用工具列表，支持按分类和关键词筛选 |
| `install_tool` | `case_id`, `tool_name` | 在目标 VPS 上安装指定工具 |
| `get_installed_tools` | `case_id` | 查看目标 VPS 上已安装的工具 (读取 /opt/.f8x/installed.json) |

### 示例: Agent 为 VPS 安装侦查工具

```
用户: 帮我在这台 VPS 上装 nuclei 和 httpx
Agent:
  1. get_installed_tools(case_id) → 检查是否已装
  2. 若未安装:
     install_tool(case_id, "nuclei") → 安装 nuclei
     install_tool(case_id, "httpx") → 安装 httpx
  3. get_installed_tools(case_id) → 确认安装成功
```

### 示例: Agent 部署完整渗透环境

```
用户: 给这台新 VPS 配一套完整渗透环境
Agent:
  1. 通过 SSH 执行 f8x -b → 基础环境
  2. 通过 SSH 执行 f8x -d → 开发环境 (Go/Python/Docker)
  3. 通过 SSH 执行 f8x -k → 完整渗透套件
  (等同于 preset: pentest-full)
```

## 注意事项

- **仅限 Linux**: f8x 主脚本仅支持 Linux (Debian/Ubuntu/CentOS/Fedora/Kali)，不要在 macOS 上执行
- **架构检测**: 自动识别 x86_64/aarch64，下载对应二进制
- **需要 root**: 大部分安装操作需要 root 权限，非 root 用户需 sudo (`--list-tools` 等查询命令除外)
- **代理设置**: 自动读取 `http_proxy`/`https_proxy` 环境变量，也可用 `-p` 安装 Proxychains
- **CI 模式**: 设置 `touch /tmp/IS_CI` 跳过交互式确认 (redc 自动设置)
- **安装路径**: 二进制工具装到 `/usr/local/bin/`，Python/Git 工具装到 `/pentest/<tool>/`
- **安装记录**: 每次成功安装记录到 `/opt/.f8x/installed.json`
- **依赖级别**: 安装前注意工具的 deps 级别，确保前置环境已就绪
- **大型工具**: 部分工具占用较大磁盘空间 (如 Viper ~2.1GB, VulFocus ~1.04GB, MobSF ~1.54GB)，小规格 VPS 注意磁盘余量
