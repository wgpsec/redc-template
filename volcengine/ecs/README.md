# 场景使用

1. 使用前请按照注意事项里内容进行配置 (若空则无需配置)
2. 使用时命令如下

拉取
```
redc pull volcengine/ecs
```

开启
```
redc run volcengine/ecs
```

查询
```
redc status [uuid]
```

关闭
```
redc stop [uuid]
```

# 注意事项

## 认证配置
需要配置火山引擎的访问凭证，有以下两种方式：

1. **环境变量方式**（推荐）
```bash
export VOLCENGINE_ACCESS_KEY="your-access-key"
export VOLCENGINE_SECRET_KEY="your-secret-key"
```

2. **配置文件方式**
在 `~/.volcengine/config` 中配置

## 常见问题
若启动场景报错，可能原因：
1. 火山引擎账户余额不足
2. 与火山引擎 API 网络连接超时
3. 火山引擎该区域售罄或下架 instance_type 的配置机型
4. 未配置正确的访问凭证（AK/SK）

## 场景配置说明
- **实例规格**: ecs.e-c1m1.large (2核2G内存)
- **计费方式**: 按量计费（PostPaid）
- **系统盘**: 20GB ESSD_PL0
- **操作系统**: Debian 12
- **登录方式**: 随机生成的SSH密码
- **区域**: 北京（cn-beijing）
