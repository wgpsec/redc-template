# Shadowsocks-libev 代理

安装 shadowsocks-libev 代理服务。

## 环境变量

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `SS_PORT` | `10443` | 代理端口 |
| `SS_PASSWORD` | `redc_proxy_default` | 代理密码 |
| `SS_METHOD` | `chacha20-ietf-poly1305` | 加密方式 |

## 使用场景

从 `aliyun/proxy` 和 `aws/proxy` 预定义模板中提取，可独立用于任意 ECS/EC2 实例。

部署后可配合 clash 配置使用，代理信息：
- 类型：ss
- 服务器：实例公网 IP
- 端口：`SS_PORT`
- 加密：`SS_METHOD`
- 密码：`SS_PASSWORD`
