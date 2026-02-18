# redc-template

中文 | [English](README.md)

https://github.com/wgpsec/redc 引擎要用到的 tf 模板仓库

模板编写教程（中文）：[WRITING_TEMPLATES_CN.md](WRITING_TEMPLATES_CN.md)

## 分类解释

按照各个云来分类

- aliyun 为 阿里云 上的各个场景
- aws 为 亚马逊云 上的各个场景
- tencent 为 腾讯云 上的各个场景
- vultr 为 vultr云 上的场景 (不是很推荐了,要用不如用 aws)
- huaweicloud 为 华为云 上的各个场景
- volcengine 为 火山引擎 上的各个场景
- **base-templates 为基础模板** (支持自定义配置的通用模板，可通过 RedC GUI 的"自定义部署"功能使用)
- **userdata-templates 为专项模板** (支持自定义配置部署，可通过 RedC GUI 的"专项模块"功能使用)

### 什么是基础模板？

基础模板是支持自定义配置的通用模板，与预定义模板的区别：

- **预定义模板**: 固定配置，一键部署，适合快速使用
- **基础模板**: 可自定义配置（云厂商、地域、实例规格等），适合灵活部署

查看 [base-templates/README.md](base-templates/README.md) 了解更多。

## 需要准备什么

阿里云
- aksk (要有能开机器、vpc、vswitch、安全组的权限,嫌麻烦就弄高权限)

腾讯云
- aksk (同上)

aws
- aksk (同上)
- launch_template id (启动模板 id,就是你自己去控制台建个启动模板，然后复制下 id 替换我tf模板里的 id 即可)
- 你自己aws控制台生成的 ssh 密钥,保存好到本地

vultr (不推荐使用)
- aksk (同上)

## 如何使用

推荐配合 redc 工具使用
- https://github.com/wgpsec/redc

> 注意：每个模板场景文件夹路径都可以单独使用，即 “不依靠 redc 引擎，独立使用“

## 文件存储的规划

运行时所需的静态资源通过模板中 github_proxy 的定义的代理链接去下载，aws 场景无需考虑代理

运行后的文件存储在 R2 存储上,通过 redc 引擎的 upload_r2 模块实现上传功能

## 安全检查

本仓库使用 GitHub Actions 自动检查敏感信息：

- **敏感信息扫描**: 自动检测代码中的访问密钥(AK)、秘密密钥(SK)、密码等敏感信息
- **CI/CD 集成**: 每次推送和 Pull Request 都会触发自动扫描
- **防止泄露**: 检测到敏感信息时，CI 会失败并阻止合并

⚠️ **重要**: 请勿将真实的 AK/SK、密码等敏感信息直接写入代码中。应使用环境变量或配置文件管理敏感信息。
