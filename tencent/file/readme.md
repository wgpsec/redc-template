# 注意事项

请自行替换模板中的静态资源下载链接

**替换 terraform.tfvars 中的 腾讯云 aksk**

```
tencentcloud_secret_id  = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
tencentcloud_secret_key = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```

**请自行替换 main.tf 中 simplehttpserver 的压缩包下载地址**
- https://github.com/projectdiscovery/simplehttpserver

对应
```
sudo wget -O simplehttpserver_0.0.5_linux_amd64.tar.gz 'https://这里替换成你自己的静态下载地址'
```

若启动场景报错，可能原因
1. 腾讯云账户余额不足
2. 与腾讯云 api 网络连接超时
3. 腾讯云该区域售罄或下架 instance_type 的配置机型

# 场景使用

1. 使用前请按照注意事项里内容进行配置 (若空则无需配置)
2. 将该场景文件夹复制到 redc/utils/redc-templates/ 路径下
3. 使用时命令如下

开启
```
./redc -start file
```

查询
```
./redc -status [uuid]
```

关闭
```
./redc -stop [uuid]
```
