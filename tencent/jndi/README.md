# 场景使用

1. 使用前请按照注意事项里内容进行配置 (若空则无需配置)
2. 使用时命令如下

拉取
```
redc pull tencent/jndi
```

开启
```
redc run tencent/jndi
```

查询
```
redc status [uuid]
```

关闭
```
redc stop [uuid]
```

# 静态资源

**替换 terraform.tfvars 中的 腾讯云 aksk**

```
tencentcloud_secret_id  = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
tencentcloud_secret_key = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```

可自行替换模板中的静态资源下载链接，目前走的是 https://ghproxy.link/ 站点的加速链接

**可自行替换 main.tf 中 jdk-8u321-linux-x64 的压缩包下载地址**
- https://github.com/No-Github/Archive/releases/tag/1.0.5

**可自行替换 main.tf 中 JNDIExploit_feihong 的压缩包下载地址**
- https://github.com/No-Github/Archive/tree/master/JNDI

**可自行替换 main.tf 中 JNDIExploit_0x727 的压缩包下载地址**
- https://github.com/No-Github/Archive/tree/master/JNDI

**可自行替换 main.tf 中 java-chains 的压缩包下载地址**
- https://github.com/vulhub/java-chains/releases

**可自行替换 main.tf 中 JNDI-Injection-Exploit 的压缩包下载地址**
- https://github.com/welk1n/JNDI-Injection-Exploit/releases

**可自行替换 main.tf 中 MemShellParty 的压缩包下载地址**
- https://github.com/ReaJason/MemShellParty/releases

**可自行替换 main.tf 中 simplehttpserver 的压缩包下载地址**
- https://github.com/projectdiscovery/simplehttpserver

**可自行替换 terraform.tfvars 中 github 加速地址**
- https://ghfast.top/github.com

# 注意事项

若启动场景报错，可能原因
1. 腾讯云账户余额不足
2. 与腾讯云 api 网络连接超时
3. 腾讯云该区域售罄或下架 instance_type 的配置机型
4. jdk未正常安装
