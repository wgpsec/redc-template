# f8x 工具部署指南

f8x 是红蓝队环境自动化部署工具，支持在 Linux VPS 上一键安装 160+ 安全、开发和运维工具。

## 安装 f8x

```bash
# 方式 1: CDN (推荐)
wget -O f8x https://f8x.io/f8x && sudo bash f8x

# 方式 2: GitHub
curl -sSL https://raw.githubusercontent.com/ffffffff0x/f8x/main/f8x -o /tmp/f8x && sudo bash /tmp/f8x

# 在 redc 管理的 VPS 上，软件商店会自动部署 f8x
```

## 常用命令

### 安装单个工具
```bash
f8x -install <tool_name>    # 如: f8x -install nuclei
```

### 搜索工具
```bash
f8x --search <keyword>      # 如: f8x --search scanner
```

### 查看所有可用工具
```bash
f8x --list-tools            # JSON 格式
f8x --list-tools table      # 表格格式
```

### 查看已安装工具
```bash
f8x --list-installed        # 输出 /opt/.f8x/installed.json
```

### 批量安装 (常用 flag)
```bash
f8x -b       # 基础环境 (gcc, make, git, curl, vim, SSH 优化)
f8x -d       # 开发环境 (Docker, Go, Python3, Node.js, Ruby, Rust)
f8x -ka      # 侦查套件 (nmap, masscan, httpx, subfinder, ffuf, dirsearch, katana...)
f8x -kb      # 漏洞利用套件 (nuclei, sqlmap, xray, WPScan...)
f8x -k       # -ka + -kb 合并
f8x -s       # 蓝队工具 (Fail2Ban, rkhunter, anti-portscan, shellpub)
```

## 工具分类 (10 类)

| 分类 | 说明 | 代表工具 |
|------|------|----------|
| basic | 基础环境和系统优化 | gcc, make, git, BBR |
| development | 开发语言和容器 | Docker, Go, Python, Node.js, Rust |
| pentest-recon | 渗透侦查 | nmap, masscan, httpx, subfinder, ffuf, katana |
| pentest-exploit | 漏洞利用 | nuclei, sqlmap, metasploit, xray |
| pentest-post | 后渗透 | impacket, hashcat, CrackMapExec, Responder |
| blue-team | 蓝队防御 | Binwalk, ClamAV, Volatility, Suricata |
| red-infra | 红队基础设施 | CobaltStrike, Sliver, frp, nps, RedGuard |
| vuln-env | 漏洞靶场 | VulHub, VulFocus, TerraformGoat |
| misc | 杂项工具 | zsh, fzf, 1Panel, AdGuard |
| system | 系统操作 | 更新, 清理日志, swap, 关闭监控 |

## 与 redc 配合使用

### 典型流程
1. 通过 redc 模板开启 VPS 场景 (userdata 自动安装核心依赖)
2. SSH 连接到 VPS
3. 按需通过软件商店 UI 或 `f8x -install` 加装额外工具

### MCP 工具 (AI Agent 可用)
- `get_f8x_catalog` — 查询可用工具列表，支持按分类和关键词筛选
- `install_tool` — 在目标 VPS 上安装指定工具
- `get_installed_tools` — 查看目标 VPS 上已安装的工具

### 示例: Agent 为 VPS 安装侦查工具
```
用户: 帮我在这台 VPS 上装 nuclei 和 httpx
Agent:
  1. get_installed_tools(case_id) → 检查是否已装
  2. install_tool(case_id, "nuclei") → 安装 nuclei
  3. install_tool(case_id, "httpx") → 安装 httpx
```

## 注意事项

- **架构检测**: f8x 自动识别 x86_64/aarch64，下载对应二进制
- **非 root 用户**: 大部分操作需要 root，非 root 用户需 sudo
- **代理设置**: f8x 自动读取 `http_proxy`/`https_proxy` 环境变量
- **CI 模式**: 设置 `touch /tmp/IS_CI` 跳过交互式确认 (redc 自动设置)
- **安装记录**: 每次成功安装记录到 `/opt/.f8x/installed.json`
- **依赖级别**: deps=0 仅需基础环境, 1=需 Python, 2=需 Go, 3=两者都需
