# CoPaw

Open source AI personal assistant; minimal installation, deployable locally or on cloud; supports multi-platform integration and easy capability extension.

## Core Capabilities

- **Omni-reach** — DingTalk, Feishu, QQ, Discord, iMessage and more channels, CoPaw connects on demand.
- **You are in control** — Memory and personalization under your control, local or cloud; scheduled and collaborative posts to designated channels.
- **Skills Extension** — Built-in scheduled tasks, custom skill directory, CoPaw auto-loads, no binding.

## Use Cases

### Social Media
- Daily hot post summaries (Xiaohongshu, Zhihu, Reddit)
- Bilibili/YouTube new video summaries

### Productivity
- Email and Newsletter highlights pushed to DingTalk/Feishu/QQ
- Email and calendar contact organization

### Creative & Building
- Set goals before bed, auto-execute, get a prototype next day
- From topic selection to finished video

### Research & Learning
- Track tech and AI news
- Personal knowledge base search and reuse

### Desktop & Files
- Organize and search local files
- Read and summarize documents

## Quick Start

### Access Console

After deployment, access http://localhost:8088 to enter the console.

### Configure AI Model

First-time use requires configuring an LLM provider:

1. Open http://localhost:8088 → Settings → Models
2. Select provider (e.g., DashScope, OpenAI, etc.)
3. Fill in API Key and enable

### Local Model Support

If using local models (no API Key required):

```bash
# Install support
pip install 'copaw[llamacpp]'

# Download model
copaw models download Qwen/Qwen3-4B-GGUF

# Start and select local model
copaw models
copaw app
```

### Connect Channels

Supports multiple communication platform integrations:

- DingTalk
- Feishu
- QQ
- Discord
- iMessage

See official documentation for details.

## Environment Variables

| Variable | Description |
|----------|-------------|
| `DASHSCOPE_API_KEY` | Aliyun DashScope API Key |
| `OPENAI_API_KEY` | OpenAI API Key |
| `MODELSCOPE_API_KEY` | ModelScope API Key |

## More Information

- Official Documentation: https://copaw.agentscope.io
- GitHub: https://github.com/agentscope-ai/CoPaw
