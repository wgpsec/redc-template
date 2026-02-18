# Linux 基础设置

这是一个用于基础系统设置，安装常用工具的 userdata 模板。

## 功能说明

该模板在 Linux 系统启动时自动执行以下操作：

1. **更新系统包** - 执行 `apt-get update -y` 和 `apt-get upgrade -y` 更新系统软件包
2. **安装常用工具** - 安装以下常用工具：
   - curl
   - wget
   - git
   - vim

## 使用方法

通过 RedC GUI 的"专项模块"或"自定义部署"功能使用此模板：

1. 选择 "Linux 基础设置" 模板
2. 点击"复制脚本"按钮
3. 在云服务器 userdata 中粘贴使用

## 适用系统

- Ubuntu / Debian 系 Linux 发行版
