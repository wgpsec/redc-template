# redc-template

https://github.com/wgpsec/redc 要用到的 tf 模板 

## 分类解释

暂时按照各个云来分类

- aliyun 为 阿里云 上的各个场景
- aws 为 亚马逊云 上的各个场景
- tencent 为 腾讯云 上的各个场景
- vultr 为 vultr云 上的场景 (不是很推荐了,要用不如用 aws)

还有 华为云、火山等等后续慢慢补充

> 若要在 1 个场景调用多个云，需要跨文件夹实现，可以，但目前没有硬需求场景，如有请提 issus 我实现

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

每个模板场景文件夹路径都可以单独使用

阿里云
- 安装 aliyun-cli 配置好 aksk
- 账户余额要大于 200 (阿里云的规定)

AWS
- 按照 awscli 配置好 aksk
- 申请开通 香港 区域使用权限

腾讯云
- 申请 aksk
- 替换 模版中的 aksk 信息
- 这个提一嘴,为啥腾讯云不用 TCCLI 因为腾讯给 tf 的provider 不支持从 TCCLI 读取 aksk(https://cloud.tencent.com/document/product/1653/82868)

vultr (不推荐使用)
- 申请 aksk
- 替换 模版中的 aksk 信息

推荐配合 redc 工具使用
- https://github.com/wgpsec/redc

## 文件存储的规划

文件暂存在 R2 存储上
