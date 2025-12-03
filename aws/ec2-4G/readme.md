# 注意事项

aws 开启 ap-east-1 (香港) 区域

![](../../img/redc-2.png)

![](../../img/redc-3.png)

自行替换 main.tf 中的 launch_template id 值

![](../../img/redc-4.png)

这个按你场景需求进行修改

```
launch_template {
        id = "这个改成你的 launch_template id 值"
    }
```

若启动场景报错，可能原因
1. 未替换 main.tf 中的 launch_template id 值
2. 与 aws api 网络连接超时
3. aws 该区域售罄或下架 instance_type 的配置机型
4. 启动模板中的安全组未开放公网访问
