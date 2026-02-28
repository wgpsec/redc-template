# CoPaw

开源 AI 个人助理；安装极简、本地与云上均可部署；支持多端接入、能力轻松扩展。

## 核心能力

- **全域触达** — 钉钉、飞书、QQ、Discord、iMessage 等频道，一个 CoPaw 按需连接。
- **由你掌控** — 记忆与个性化由你掌控，本地或云端均可；定时与协作发往指定频道。
- **Skills 扩展** — 内置定时任务，自定义技能目录，CoPaw 自动加载，无绑定。

## 使用场景

### 社交媒体
- 每日热帖摘要（小红书、知乎、Reddit）
- B 站/YouTube 新视频摘要

### 生产力
- 邮件与 Newsletter 精华推送到钉钉/飞书/QQ
- 邮件与日历整理联系人

### 创意与构建
- 睡前说明目标、自动执行，次日获得雏形
- 从选题到成片全流程

### 研究与学习
- 追踪科技与 AI 资讯
- 个人知识库检索复用

### 桌面与文件
- 整理与搜索本地文件
- 阅读与摘要文档

## 快速开始

### 访问控制台

部署完成后，访问 http://localhost:8088 进入控制台。

### 配置 AI 模型

首次使用需要配置 LLM 提供商：

1. 打开 http://localhost:8088 → 设置 → 模型
2. 选择提供商（如 DashScope、OpenAI 等）
3. 填写 API Key 并启用

### 本地模型支持

如使用本地模型（无需 API Key）：

```bash
# 安装支持
pip install 'copaw[llamacpp]'

# 下载模型
copaw models download Qwen/Qwen3-4B-GGUF

# 启动并选择本地模型
copaw models
copaw app
```

### 接入频道

支持多种通讯平台接入：

- 钉钉
- 飞书
- QQ
- Discord
- iMessage

详见官方文档。

## 环境变量

| 变量 | 说明 |
|------|------|
| `DASHSCOPE_API_KEY` | 阿里云 DashScope API Key |
| `OPENAI_API_KEY` | OpenAI API Key |
| `MODELSCOPE_API_KEY` | ModelScope API Key |

## 更多信息

- 官方文档：https://copaw.agentscope.io
- GitHub：https://github.com/agentscope-ai/CoPaw
