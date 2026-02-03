# 场景使用

1. 使用前请 **一定** 按照注意事项里内容进行配置 (若空则无需配置)
2. 使用时命令如下

拉取
```
redc pull aws/md
```

开启
```
redc run aws/md
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

可自行替换模板中的静态资源下载链接

**docker-compose.yml 配置**
- https://github.com/No-Github/Archive/releases/download/1.0.8/docker-compose.yml

# 注意事项

**区域配置**

aws 开启 ap-east-1 (香港) 区域

![](../../img/redc-2.png)

![](../../img/redc-3.png)

若启动场景报错，可能原因
1. 与 aws api 网络连接超时
2. aws 该区域售罄或下架 instance_type 的配置机型
3. AMI 架构与 instance_type 不匹配
4. f8x 自动安装 docker 失败
