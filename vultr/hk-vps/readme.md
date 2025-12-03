# 注意事项

**配置 vultr api key**

在 deploy.sh 中配置

这里 xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 要替换成 vultr 的 api kye
```
    -start)
        start_vps "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
        ;;
    -stop)
        stop_vps "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
        ;;
    -status)
        status_vps "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
        ;;
```

若启动场景报错，可能原因
1. 与 vultr api 网络连接超时
2. vultr 该区域售罄或下架 vultr_instance 的配置机型 (plan)

