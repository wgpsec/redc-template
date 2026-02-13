# Vultr VPS 场景使用说明

## 配置 Vultr API Key

### 方法 1: 使用 redc 配置文件（推荐）

编辑 `~/redc/config.yaml`，添加 Vultr 配置：

```yaml
providers:
  vultr:
    VULTR_API_KEY: "your_vultr_api_key_here"
```

### 方法 2: 使用环境变量

```bash
export VULTR_API_KEY="your_vultr_api_key_here"
```

### 方法 3: 在 deploy.sh 中配置（不推荐）

在 deploy.sh 中配置，将 `xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx` 替换成 Vultr 的 API key：

```bash
    -start)
        start_vps "your_vultr_api_key_here"
        ;;
    -stop)
        stop_vps "your_vultr_api_key_here"
        ;;
    -status)
        status_vps "your_vultr_api_key_here"
        ;;
```

## 场景说明

- **配置**: plan vc2-1c-2gb (1核2G内存)
- **区域**: sgp (新加坡)
- **操作系统**: os_id 477
- **启动脚本**: 使用 init.sh 自动初始化环境

## 使用 redc 启动场景

```bash
# 创建并启动场景
redc run vultr/hk-vps

# 或者分步操作
redc plan vultr/hk-vps
redc start <case_id>
```

## 可能的错误原因

1. **与 Vultr API 网络连接超时**
   - 检查网络连接
   - 检查是否需要配置代理

2. **Vultr 该区域售罄或下架该配置机型**
   - 尝试更换区域（修改 main.tf 中的 region）
   - 尝试更换机型（修改 main.tf 中的 plan）

3. **API Key 配置错误**
   - 确认 API Key 是否正确
   - 确认 API Key 是否有足够的权限

## 更新说明

- 已更新 Terraform Provider 版本至 2.22.1（最新版本）
- 已添加标准 SSH 输出，支持 redc 的 SSH 运维功能
- 已在 redc 配置系统中添加 Vultr 支持
