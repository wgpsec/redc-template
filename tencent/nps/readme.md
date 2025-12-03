# 注意事项

请自行替换模板中的静态资源下载链接

**替换 terraform.tfvars 中的 腾讯云 aksk**

```
tencentcloud_secret_id  = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
tencentcloud_secret_key = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```

**请自行替换 main.tf 中 linux_amd64_server.tar.gz 的压缩包下载地址**
- https://github.com/ehang-io/nps/releases

对应
```
sudo wget -O linux_amd64_server.tar.gz 'https://这里替换成你自己的静态下载地址'
```

若启动场景报错，可能原因
1. 腾讯云账户余额不足
2. 与腾讯云 api 网络连接超时
3. 腾讯云该区域售罄或下架 instance_type 的配置机型
4. jdk未正常安装
