# 场景使用

1. 使用前请按照注意事项里内容进行配置 (若空则无需配置)
2. 使用时命令如下

拉取
```
redc pull aliyun/yakit
```

开启
```
redc run aliyun/yakit
```

查询
```
redc status [uuid]
```

关闭
```
redc stop [uuid]
```

3. 部署完成后，可以通过以下方式连接 yakit 服务器：
   - 使用 yakit 客户端连接到服务器 IP 的 8087 端口（默认）
   - SSH 登录到服务器：`ssh root@<服务器IP>`，密码在 `redc status` 输出中

# 静态资源

本场景中 yakit 服务端（yak）从阿里云 OSS 存储桶直接下载，无需配置 GitHub 代理。

下载链接：https://yaklang.oss-cn-beijing.aliyuncs.com/yak/latest/yak_linux_amd64

如需更换版本或下载地址，可在 main.tf 的 user_data 部分修改下载链接。

# 注意事项

**端口配置**

默认 yakit 服务端监听端口为 8087，可以通过修改 `terraform.tfvars` 中的 `yakit_port` 参数来自定义端口。

```
yakit_port = 8087
```

或在运行时通过 `-e` 参数指定：
```
redc run aliyun/yakit -e yakit_port=9999
```

**实例规格**

本场景使用 ecs.c7a.large 规格（2核4G），如果该规格在某些地区不可用或售罄，可以修改 main.tf 中的 `instance_type` 为其他规格，例如：
- ecs.n1.small (1核2G)
- ecs.c7.large (2核4G)
- ecs.g7.large (2核8G)

**区域配置**

默认部署在北京地区 (cn-beijing)，可以在 versions.tf 中修改 `region` 参数来更改部署区域。

若启动场景报错，可能原因：
1. 阿里云账户余额不足 (需要大于 200)
2. 与阿里云 API 网络连接超时
3. 阿里云该区域售罄或下架 instance_type 的配置机型
4. yakit 服务启动失败，可登录服务器查看日志：`systemctl status yakit`
5. OSS 下载链接失效或网络问题导致无法下载 yak 二进制文件
