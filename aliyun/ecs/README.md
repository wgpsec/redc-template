# 注意事项

若启动场景报错，可能原因
1. 阿里云账户余额不足 (需要大于 200)
2. 与阿里云 api 网络连接超时
3. 阿里云该区域售罄或下架 instance_type 的配置机型

# 场景使用

1. 使用前请按照注意事项里内容进行配置 (若空则无需配置)
2. 将该场景文件夹复制到 redc/utils/redc-templates/ 路径下
3. 使用时命令如下

开启
```
./redc -start ecs
```

查询
```
./redc -status [uuid]
```

关闭
```
./redc -stop [uuid]
```
