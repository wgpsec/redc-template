# Spring Core RCE (CVE-2022-22965)

## 漏洞简介

Spring Framework 远程代码执行漏洞，攻击者可利用 SpEL 表达式注入执行任意代码。该漏洞存在于 Spring 框架的参数绑定机制中，通过构造特殊的请求参数可以触发 SpEL 表达式执行。

## CVE 信息

- **CVE 编号**: CVE-2022-22965
- **漏洞类型**: RCE (远程代码执行)
- **危险等级**: Critical (严重)
- **影响版本**: Spring Framework 5.3.0 ~ 5.3.17

## 环境信息

- **镜像**: vulhub/spring-core-rce
- **端口**: 8080
- **服务**: Spring Core RCE 测试环境

## 使用方法

1. 在云服务器上执行 userdata 脚本
2. 脚本会自动安装 Docker 并启动 Spring Core 漏洞环境
3. 访问 `http://<your-ip>:8080` 进行测试

## 测试方法

```bash
# 使用 curl 发送恶意请求（需要根据实际环境调整）
curl -X POST "http://<your-ip>:8080" -d "class.module.classLoader.resources.context.parent.pipeline.first.pattern=%23"
```

## 注意事项

- 此环境仅用于安全研究
- 请在防火墙中限制访问来源
- 测试完成后请及时删除环境

## 参考链接

- [Vulhub Spring Core RCE 漏洞环境](https://github.com/vulhub/vulhub/tree/master/spring/CVE-2022-22965)
- [NVD CVE-2022-22965](https://nvd.nist.gov/vuln/detail/CVE-2022-22965)
