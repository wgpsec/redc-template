# redc-template 模板编写教程（中文）

本教程说明如何为 redc 引擎 https://github.com/wgpsec/redc 编写符合仓库规范的模板，适用于阿里云、AWS、腾讯云等多云场景。参考现有示例：
- AWS 通用场景：[aws/ec2](aws/ec2)
- 阿里云代理场景：[aliyun/proxy](aliyun/proxy)

## 模板类型

redc 支持四种模板类型，通过 `case.json` 中的 `template` 字段区分：

| 类型 | template 值 | 目录 | 用途 |
|------|------------|------|------|
| 预定义模板 | `preset` 或不填 | `aliyun/`、`aws/`、`tencent/` 等 | 场景管理页面使用 |
| 自定义部署模板 | `base` | `base-templates/` | 自定义部署使用 |
| Userdata 模板 | `userdata` | `userdata-templates/` | 自定义部署和专项场景使用 |
| Compose 模板 | `compose` | `compose-templates/` | 编排管理使用 |

### case.json 模板类型标记示例

**预定义模板**（默认，可不填）：
```json
{
  "name": "ecs",
  "description": "阿里云 ECS 实例",
  "version": "1.0.0",
  "user": "redc",
  "provider": "alicloud"
}
```

**自定义部署模板**：
```json
{
  "name": "alicloud-ecs",
  "description": "阿里云 ECS 实例",
  "version": "1.0.5",
  "user": "redc",
  "provider": "alicloud",
  "template": "base"
}
```

**Userdata 模板**：
```json
{
  "name": "docker-installation-bash",
  "name_zh": "Docker 安装脚本",
  "type": "bash",
  "category": "basic",
  "template": "userdata",
  "script": "#!/bin/bash\n..."
}
```

**Compose 模板**：
```json
{
  "name": "compose-example",
  "description": "Compose 示例",
  "template": "compose"
}
```

## 目录与命名
- 路径规则：`<cloud>/<scene>`，如 `aws/ec2`、`aliyun/proxy`，保持小写无空格。
- 每个场景目录内部的推荐文件：`case.json`、`README.md`、`versions.tf`、`main.tf`、`variables.tf`、`terraform.tfvars`、`outputs.tf`、`deploy.sh` (可选)；对于预定义场景，建议同时提供中文 `README.md` 和英文 `README_EN.md` 作为交付形态。

## 文件规范
- `case.json`
  - 字段：`name`、`user`、`version`、`description`、`tags`（标签数组，用于分类筛选）。
  - 如需绑定插件，添加 `redc_plugins` 字段，值为逗号分隔的插件名称，例如 `"redc_plugins": "redc-plugin-clash-config,redc-plugin-upload-r2"`（见 [aliyun/proxy/case.json](aliyun/proxy/case.json)）。
  - 插件开发详见 [插件开发指南](doc/plugin-development.md)。
- `README.md`
  - 写清 redc 命令：`redc pull <path>`、`redc run <path>`、`redc status [uuid]`、`redc stop [uuid]`。
  - 对于预定义场景，建议同时提供中文 `README.md` 和英文 `README_EN.md`；`README.md` 使用本文定义的中文契约标题，`README_EN.md` 使用英文指南中的英文契约标题。
  - 标明必须手动替换的参数（如 `launch_template id`、区域、密钥）；如场景存在高频失败点，可按需写入“常见问题”；补充提醒归入“注意事项”。

### 预定义场景 README 章节规范

- 适用范围：
  - 强制生效：预定义场景模板（各云厂商目录下的场景模板）。
  - 参考使用：`base-templates/`、`userdata-templates/`、`compose-templates/`、`plugins/`。
- 建议交付形态：预定义场景建议同时提供中文 `README.md` 和英文 `README_EN.md`；中文 `README.md` 使用本节定义的中文标题，英文 `README_EN.md` 使用英文指南中的英文标题。
- 标题身份必须保持稳定，便于下游消费方持续、准确地识别各章节。
- 四个必选章节标题必须保持完全一致，并统一使用二级标题（`##`）。
- 四个必选章节必须连续按以下顺序编写，中间不要插入其他同级标题：场景说明、前置条件、快速使用、参数说明；四个标题按既定顺序出现，各自只出现一次。
- 可选章节如需补充，也统一使用二级标题（`##`），并放在上述四个必选章节之后；只能使用固定标准标题：输出说明、常见问题、注意事项、附录，并按需出现，各自只出现一次。
- 场景说明只写场景用途、适用情况、部署后得到什么，不展开实现细节和设计背景。
- 前置条件只放运行前准备或必须手动替换的内容，如账号权限、基础资源、配额、网络或工具依赖。
- 快速使用保留最小可跑通的 `redc-cli` 路径，优先给出最短命令链路，不混入大段解释。
- 参数说明至少覆盖参数名、是否必填、默认值、示例和行为影响，避免把运行前准备或手动替换内容分散进来。
- 运行前准备统一放在前置条件，字段级参数解释统一放在参数说明。
- 当部署输出会驱动用户下一步操作时，建议将“输出说明”单独保留，用于说明关键信息、访问入口或产出物。
- 不要把所有内容塞进注意事项；注意事项只保留容易遗漏但又不适合放入前述章节的补充提醒。
- 架构图、设计限制、长配置示例等内容统一后置到附录，避免影响主流程阅读。

### 预定义场景 README 最小骨架

````md
# 模板名称

## 场景说明

说明该场景的用途、适用情况，以及部署完成后可以得到什么。

## 前置条件

- 列出运行前必须满足的账号、权限、配额、网络或依赖要求，以及运行前必须手动替换的内容。

## 快速使用

保留最小可跑通的 redc-cli 使用路径，例如：

```bash
redc pull <cloud>/<scene>
redc run <cloud>/<scene>
redc status [uuid]
redc stop [uuid]
```

## 参数说明

集中说明参数名、是否必填、默认值、示例和参数行为影响。

以下可选章节按需追加；前四段必须保留，下面四段按实际场景补充。

## 输出说明

当部署输出会驱动用户下一步操作时，在这里说明关键信息、访问入口或生成物。

## 常见问题

列出最常见的报错、触发原因和排查方法。

## 注意事项

补充容易遗漏但不适合放在前置条件、参数说明或输出说明中的提醒。

## 附录

放置架构图、设计限制、长配置示例或扩展说明。
````
- `versions.tf`
  - 锁定 provider 版本，避免兼容性问题（示例 [aws/ec2/versions.tf](aws/ec2/versions.tf)）。
- `main.tf`
  - 定义 provider/region、核心资源、`user_data` 初始化脚本。
  - 避免硬编码敏感信息，改用变量传入；必要依赖用 `depends_on`。
- `variables.tf`
  - 声明所有需要外部传入的变量，标注描述。
- `terraform.tfvars`（可选）
  - 放非敏感默认值（如端口、文件名），不要写入 AKSK/密钥。
- `outputs.tf`
  - 输出 redc 或用户可能用到的信息：公网 IP/DNS、生成文件名、存储地址等（示例 [aws/ec2/outputs.tf](aws/ec2/outputs.tf)）。
- `deploy.sh` (非强制，可不写)
  - 提供 `-init/-start/-stop/-status` 封装 `terraform init/apply/destroy/output`，便于不依赖 redc 直接使用（示例 [aws/ec2/deploy.sh](aws/ec2/deploy.sh)）。

## redc 集成要点
- 场景路径即 redc 命令参数：`redc pull aliyun/proxy`，`redc run aws/ec2`。
- 需要额外自动化（如生成 Clash 配置、上传 R2、更新 DNS）时，在 `case.json` 写 `redc_plugins`，绑定对应插件。插件会在场景生命周期的关键节点自动执行钩子脚本。
- 国内场景运行时静态资源可通过模板里的 `github_proxy` 链接加速下载；国外场景可直接从 github 直链下载，运行结果上传可由 `redc-plugin-upload-r2` 插件处理。

## 编写流程（推荐）
1) 创建目录 `cloud/scene` 并放置必备文件骨架。
2) 编写 `main.tf` 和 `variables.tf`，先确保本地 `terraform init` 成功。
3) 编写 README；对于预定义场景，建议同时提供中文 `README.md` 和英文 `README_EN.md`，并分别使用各自语言版本的契约标题；正文中强调必须手动替换的参数，如场景存在高频失败点，再按需补充常见问题；补充提醒再放到注意事项。
4) 补充 `outputs.tf`，让 redc 能读到关键数据。
5) 如需脚本化，写好 `deploy.sh` 并与 README 一致。 (非强制，可不写)
6) 本地验证：`terraform validate`，再试跑 `terraform apply -auto-approve`（使用测试账户/低配实例），确认 destroy 也正常。

## 最佳实践与注意事项
- 地域/规格：固定一个默认区域，并在 README 写明可替换项；云厂商售罄时提醒用户切换可用区。
- 安全组与放行：确保实例安全组开放必要端口；如果依赖公网访问，明确告知需要放行。
- 初始化脚本：`user_data` 中预装必要工具、网络优化；若禁用元数据访问，记得调整防火墙（示例 [aws/ec2/main.tf](aws/ec2/main.tf)）。
- 资源命名：简短且可区分，避免与用户现有资源冲突。
- 敏感信息：不要把 AKSK、SSH 私钥、密码写入仓库；必要时用变量注入。
- 兼容性：若依赖特定 provider 版本或特性，在 README 标注；Terraform 版本尽量保持当前仓库一致。

## 常见问题排查模板
- 启动失败：检查必填参数是否替换（如 launch_template id）、网络超时、实例规格售罄、安全组未放行。
- 输出为空：确认 `outputs.tf` 的资源名与 `main.tf` 一致，并在资源创建后再引用。
- 脚本执行异常：在 `user_data` 增加基础日志，或改用云厂商控制台查看启动日志。

## 提交流程
- 确认本地测试通过，清理无用文件（如 `.terraform`）。
- 保持 README/脚本与实际参数一致。
- 提交前自检：`terraform validate`、核对 `case.json` 版本号、`README` 路径命令无误。
