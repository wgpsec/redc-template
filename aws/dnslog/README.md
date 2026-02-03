# 场景使用

1. 使用前请 **一定** 按照注意事项里内容进行配置 (若空则无需配置)
2. 使用时命令如下

拉取
```
redc pull aws/dnslog
```

开启
```
redc run aws/dnslog -e domain=dnslog.com

# domain 是你的 dnslog 域名
```

查询
```
redc status [uuid]
```

关闭
```
redc stop [uuid]
```

3. 如果未配置 cf api 该场景创建完毕后需要手动修改 cname

# 静态资源

可自行替换模板中的静态资源下载链接

**dig.pm 配置**
- https://github.com/yumusb/DNSLog-Platform-Golang

可以用我编译好的版本 (没啥区别,也可以自己编译原版)
- https://github.com/No-Github/pdnslog/releases/tag/v1.0.0

# 注意事项

**区域配置**

aws 开启 ap-east-1 (香港) 区域

![](../../img/redc-2.png)

![](../../img/redc-3.png)

**cf 配置**

申请 API 令牌

配置类似如下 (ip 先随便填一个)(域名加个 ns1)
```
# A ns1 1.2.34
# NS a ns1.dnslog.com
```

**redc config.yaml 配置**

config.yaml 中配置你的 cf 的 邮箱 和 accesskey

若启动场景报错，可能原因
1. 与 aws api 网络连接超时
2. aws 该区域售罄或下架 instance_type 的配置机型
3. AMI 架构与 instance_type 不匹配
4. cf 的 dns 配置不对
5. cf 的 key 权限不够
