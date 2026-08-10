# redc-plugin-pojun-proxy

在代理场景部署成功后，为 PoJun Worker 生成私有、可校验的 Shadowsocks 代理节点 bundle。
场景成功销毁后，插件会删除该 bundle 并撤销节点数和 revision 输出，避免消费者继续使用
已经不存在的代理节点。

## 生成内容

插件在场景目录下固定生成：

```text
pojun-proxy/
└── bundle.json
```

- `bundle.json`：单个自包含文件，包含 schema 版本、稳定代理池 ID、来源 Case、规范化节点 revision 和 Mihomo/Clash 兼容的 Shadowsocks 节点数组；不包含本地监听、DNS、规则、控制端口或代理组。

在 macOS/Linux 上目录权限为 `0700`，`bundle.json` 权限为 `0600`；Windows 使用当前用户 Case 目录继承的 ACL。该文件含代理密码，不应上传到公开存储、提交到 Git 或粘贴到日志中。

## 依赖

- redc `3.3.8` 或更高版本
- 无额外命令行依赖；插件使用 redc 的 Go Template 引擎，可在 Windows、macOS 和 Linux 运行

## 安装

从插件市场安装，或在 redc-template 源码目录中安装本地版本：

```bash
redc plugin install ./plugins/redc-plugin-pojun-proxy
```

`aliyun/proxy` 模板已在 `case.json` 中声明该插件。场景在 Terraform apply 成功后会通过
跨平台 `.tmpl` hook 自动生成 bundle，并在 Terraform destroy 成功后通过同类 hook 撤销。

## 配置

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `pool_id` | string | 否 | 稳定代理池 ID；留空时使用 `redc-<case-id>-aliyun-proxy`。仅允许字母、数字、`.`、`_`、`:`、`-`，最长 128 字符。 |

节点地址来自 Terraform output `ecs_ip`，兼容 `public_ip`；端口和密码按以下优先级读取：

1. 当前 Case 运行参数 `REDC_CASE_VARS`。
2. 场景目录的 `terraform.tfvars`。

加密算法固定为 `chacha20-ietf-poly1305`，与 `aliyun/proxy` 服务端配置保持一致。

## 输出

插件通过 redc 的结构化输出协议提供以下字段：

| 字段 | 说明 |
|------|------|
| `pojun_proxy_bundle_file` | `bundle.json` 的绝对路径。 |
| `pojun_proxy_pool_id` | 稳定代理池 ID。 |
| `pojun_proxy_node_count` | bundle 中的节点数量。 |
| `pojun_proxy_revision` | 规范化 `nodes` 数组的 SHA-256，也是后续同步的修订标识。 |

```bash
redc status <case-id> -o json | jq '.plugin_outputs'
```

插件会拒绝空节点、重复节点、非法 IPv4、空密码、非法端口和非法 pool ID。校验失败时不会替换上一次成功生成的 bundle。
