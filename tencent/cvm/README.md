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

**非 redc 使用请自行替换 terraform.tfvars 中的 腾讯云 aksk**

```
tencentcloud_secret_id  = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
tencentcloud_secret_key = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```

# 注意事项

若启动场景报错，可能原因
1. 腾讯云账户余额不足
2. 与腾讯云 api 网络连接超时
3. 腾讯云该区域售罄或下架 instance_type 的配置机型
