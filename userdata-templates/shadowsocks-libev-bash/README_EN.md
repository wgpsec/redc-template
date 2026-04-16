# Shadowsocks-libev Proxy

Install shadowsocks-libev proxy service.

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `SS_PORT` | `10443` | Proxy port |
| `SS_PASSWORD` | `redc_proxy_default` | Proxy password |
| `SS_METHOD` | `chacha20-ietf-poly1305` | Encryption method |

## Use Case

Extracted from the `aliyun/proxy` and `aws/proxy` preset templates. Can be used independently with any ECS/EC2 instance.

After deployment, use with a Clash configuration. Proxy details:
- Type: ss
- Server: Instance public IP
- Port: `SS_PORT`
- Encryption: `SS_METHOD`
- Password: `SS_PASSWORD`
