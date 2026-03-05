# 场景使用

1. 使用前请 **一定** 按照注意事项里内容进行配置 (若空则无需配置)
2. 使用时命令如下

拉取
```
redc pull aws/MHDDoS
```

开启
```
redc run aws/MHDDoS
```

查询
```
redc status [uuid]
```

关闭
```
redc stop [uuid]
```

# 参数说明

| 参数 | 说明 | 默认值 |
|------|------|--------|
| node | 节点数量 | 1 |
| ddos_target | 攻击目标 (IP 或域名) | - |
| ddos_threads | 攻击线程数 | 100 |
| ddos_time | 攻击持续时间 (秒) | 3600 |
| ddos_mode | 攻击模式 (layer7/layer4) | layer7 |

# 攻击模式说明

- **layer7**: HTTP Flood, GET/POST 洪水攻击
- **layer4**: TCP/UDP 洪水攻击

# 注意事项

**区域配置**

aws 开启 ap-east-1 (香港) 区域

![](../../img/redc-2.png)

![](../../img/redc-3.png)

**使用限制**

本工具仅供 **授权的渗透测试** 使用，未经目标授权的 DDoS 攻击是违法行为。

若启动场景报错，可能原因
1. 与 aws api 网络连接超时
2. aws 该区域售罄或下架 instance_type 的配置机型
3. AMI 架构与 instance_type 不匹配
