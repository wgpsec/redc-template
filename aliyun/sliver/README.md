# 场景使用

1. 使用前请按照注意事项里内容进行配置 (若空则无需配置)
2. 使用时命令如下

拉取
```
redc pull aliyun/sliver
```

开启
```
redc run aliyun/sliver
```

登录后下载sliver.cfg,本地导入使用
```
sliver import ./sliver.cfg
# 运行
sliver
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

可自行替换模板中的静态资源下载链接，目前走的是 https://ghproxy.link/ 站点的加速链接

**可自行替换 main.tf 中 sliver-server_linux 的压缩包下载地址**
- https://github.com/BishopFox/sliver/releases

**可自行替换 main.tf 中 sliver-client_linux 的压缩包下载地址**
- https://github.com/BishopFox/sliver/releases

**可自行替换 main.tf 中 simplehttpserver 的压缩包下载地址**
- https://github.com/projectdiscovery/simplehttpserver

**可自行替换 terraform.tfvars 中 github 加速地址**
- https://ghfast.top/github.com

# 注意事项

若启动场景报错，可能原因
1. 阿里云账户余额不足 (需要大于 200)
2. 与阿里云 api 网络连接超时
3. 阿里云该区域售罄或下架 instance_type 的配置机型
4. sliver部署方式更新，导致user_data中的配置过时
