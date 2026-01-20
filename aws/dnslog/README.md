# 注意事项

**区域配置**

aws 开启 ap-east-1 (香港) 区域

![](../../img/redc-2.png)

![](../../img/redc-3.png)

**launch_template 配置**

自行替换 main.tf 中的 launch_template id 值

![](../../img/redc-4.png)

这个按你场景需求进行修改

```
launch_template {
        id = "这个改成你的 launch_template id 值"
    }
```

**cf 配置**

申请 API 令牌

配置类似如下 (ip 先随便填一个)(域名加个 ns1)
```
# A ns1 1.2.34
# NS a ns1.dnslog.com
```

**deploy.sh 配置**

CFAddRecords 传参中的 cf 的 邮箱 和 accesskey
```
CFAddRecords "你的 cf 邮箱" "你的 cf accesskey" $2 "ns1.$2" "$ecs_ip"
```

**dig.pm 配置**
- https://github.com/yumusb/DNSLog-Platform-Golang

可以用我编译好的版本 (没啥区别,也可以自己编译原版)
- https://github.com/No-Github/pdnslog/releases/tag/v1.0.0

自行替换 main.tf 中几处静态文件下载地址
```
sudo wget -O pdnslog 'https://这里替换成你自己的静态下载地址'
sudo wget -O index.html 'https://这里替换成你自己的静态下载地址'
sudo wget -O main.js 'https://这里替换成你自己的静态下载地址'
sudo wget -O dashboard.css 'https://这里替换成你自己的静态下载地址'
sudo wget -O bootstrap.min.css 'https://这里替换成你自己的静态下载地址'
```

若启动场景报错，可能原因
1. 未替换 main.tf 中的 launch_template id 值
2. 与 aws api 网络连接超时
3. aws 该区域售罄或下架 instance_type 的配置机型
4. 启动模板中的安全组未开放公网访问
5. cf 的 dns 配置不对
6. cf 的 key 权限不够

# 场景使用

1. 使用前请按照注意事项里内容进行配置 (若空则无需配置)
2. 将该场景文件夹复制到 redc/utils/redc-templates/ 路径下
3. 使用时命令如下

开启
```
./redc -start dnslog -domain dnslog.com

# domain 是你的 dnslog 域名
```

查询
```
./redc -status [uuid]
```

关闭
```
./redc -stop [uuid]
```

4. 如果未配置 cf api 该场景创建完毕后需要手动修改 cname
