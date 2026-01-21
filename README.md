# redc-template

https://github.com/wgpsec/redc 要用到的 tf 模板

## 分类解释

暂时按照各个云来分类

- aliyun 为 阿里云 上的各个场景
- aws 为 亚马逊云 上的各个场景
- tencent 为 腾讯云 上的各个场景
- vultr 为 vultr云 上的场景 (不是很推荐了,要用不如用 aws)

还有 华为云、火山等等后续慢慢补充

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

文件暂存在 R2 存储上
