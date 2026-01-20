# 注意事项

请自行替换模板中的静态资源下载链接

**请自行替换 main.tf 中 sliver-server_linux 的压缩包下载地址**
- https://github.com/BishopFox/sliver/releases

对应
```
sudo wget -O sliver-server_linux 'https://这里替换成你自己的静态下载地址'
```

**请自行替换 main.tf 中 sliver-client_linux 的压缩包下载地址**
- https://github.com/BishopFox/sliver/releases

对应
```
sudo wget -O sliver-client_linux 'https://这里替换成你自己的静态下载地址'
```

**请自行替换 main.tf 中 simplehttpserver 的压缩包下载地址**
- https://github.com/projectdiscovery/simplehttpserver

对应
```
sudo wget -O simplehttpserver_0.0.5_linux_amd64.tar.gz 'https://这里替换成你自己的静态下载地址'
```

若启动场景报错，可能原因
1. 阿里云账户余额不足 (需要大于 200)
2. 与阿里云 api 网络连接超时
3. 阿里云该区域售罄或下架 instance_type 的配置机型
4. sliver部署方式更新，导致user_data中的配置过时

# 场景使用

1. 使用前请按照注意事项里内容进行配置 (若空则无需配置)
2. 将该场景文件夹复制到 redc/utils/redc-templates/ 路径下
3. 使用时命令如下

开启
```
./redc -start sliver
```

登录后下载sliver.cfg,本地导入使用
```
sliver import ./sliver.cfg
# 运行
sliver
```


查询
```
./redc -status [uuid]
```

关闭
```
./redc -stop [uuid]
```
