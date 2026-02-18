# Userdata Templates

专项模板目录，包含用于自定义部署的用户数据脚本模板。

## 目录结构

每个模板目录包含以下文件：

```
<template-name>/
├── case.json    # 模板元数据
└── userdata    # 用户数据脚本内容
```

## case.json 字段说明

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| name | string | 是 | 模板名称（英文唯一标识） |
| nameZh | string | 是 | 中文名称 |
| type | string | 是 | 脚本类型：`bash` 或 `powershell` |
| category | string | 是 | 分类：`basic`（基础）、`ai`（AI场景） |
| user | string | 是 | 作者用户名 |
| version | string | 是 | 版本号，格式：`x.y.z` |
| url | string | 否 | 官方网址 |
| description | string | 否 | 描述信息 |
| installNotes | string | 否 | 安装后的注意事项 |

## 使用方式

通过 RedC GUI 的"专项模块"功能使用：

1. 打开 RedC GUI
2. 进入"专项模块"页面
3. 选择相应的标签页（如"AI场景"）
4. 选择模板并复制使用
