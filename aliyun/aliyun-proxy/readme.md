# 注意事项

deploy.sh 中的 upload_to_r2 函数负责将 clash 配置传至 r2

请自行安装 rclone 并设置 rclone 与 r2 的配置
- https://github.com/rclone/rclone/releases
- https://dash.cloudflare.com/ 的 r2

![](../../img/redc-1.png)

```
rclone config
s3
Cloudflare R2 Storage
xxxxxxxxxxxxx
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
https://xxxxxxxxxxxxxxxxxx.r2.cloudflarestorage.com
auto

rclone lsf r2:test
```

若启动场景报错，可能原因
1. 阿里云账户余额不足 (需要大于 200)
2. 与阿里云 api 网络连接超时
3. 阿里云改区域售罄或下架 instance_type 的配置机型
4. rclone配置不正确
5. r2 存储桶名称和配置不一致