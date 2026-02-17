# RedC 基础模板

基础模板是支持自定义配置的通用模板，可以通过 RedC GUI 的"自定义部署"功能进行灵活配置。

## 什么是基础模板？

基础模板与预定义模板的区别：

- **预定义模板**: 固定配置，一键部署，适合快速使用
- **基础模板**: 可自定义配置（云厂商、地域、实例规格等），适合灵活部署

## 如何使用基础模板？

### 方法 1: 使用现有基础模板

1. 在 RedC GUI 中，进入"模板仓库"
2. 找到 `base-templates` 目录下的模板
3. 点击"拉取"将模板下载到本地
4. 进入"自定义部署"页面
5. 选择基础模板并配置参数
6. 点击"创建部署"

### 方法 2: 将现有模板转换为基础模板

1. 在"本地模板管理"中选择一个模板
2. 点击"编辑模板"
3. 编辑 `case.json` 文件，添加以下字段：

```json
{
  "name": "your-template-name",
  "description": "模板描述",
  "version": "1.0.0",
  "user": "作者名称",
  "provider": "支持的云厂商",
  "is_base_template": true
}
```

4. 在 `variables.tf` 中定义可配置的变量：

```hcl
variable "provider" {
  description = "云厂商"
  type        = string
}

variable "region" {
  description = "地域"
  type        = string
}

variable "instance_type" {
  description = "实例规格"
  type        = string
}
```

5. 在 `main.tf` 中使用条件资源创建：

```hcl
resource "alicloud_instance" "this" {
  count = var.provider == "alicloud" ? 1 : 0
  
  instance_type = var.instance_type
  # ... 其他配置
}

resource "tencentcloud_instance" "this" {
  count = var.provider == "tencentcloud" ? 1 : 0
  
  instance_type = var.instance_type
  # ... 其他配置
}
```

6. 保存后刷新"自定义部署"页面

## 创建自己的基础模板

参考 `volcengine-ecs` 模板的结构：

```
your-template/
├── case.json          # 模板元数据（必须包含 is_base_template: true）
├── variables.tf       # 变量定义
├── main.tf           # 主配置文件
├── data.tf           # 数据源
├── network.tf        # 网络资源
├── output.tf         # 输出
└── README.md         # 说明文档
```

### 关键要点

1. **case.json** 必须包含：
   - `is_base_template: true`
   - `supported_providers: [...]`

2. **variables.tf** 应该定义：
   - `provider`: 云厂商
   - `region`: 地域
   - `instance_type`: 实例规格
   - 其他自定义变量

3. **main.tf** 使用条件创建资源：
   - 使用 `count = var.provider == "xxx" ? 1 : 0`
   - 为每个云厂商创建对应的资源

4. **output.tf** 提供统一的输出格式

## 最佳实践

1. **变量验证**: 在 variables.tf 中添加验证规则
2. **默认值**: 为非必需变量提供合理的默认值
3. **文档**: 在 README.md 中详细说明使用方法
4. **测试**: 在多个云厂商上测试模板
5. **版本管理**: 使用语义化版本号

## 常见问题

### Q: 为什么我的模板没有出现在自定义部署页面？

A: 检查以下几点：
1. `case.json` 中是否有 `"is_base_template": true`
2. 模板是否在本地模板目录中
3. 尝试刷新页面

### Q: 如何支持更多云厂商？

A: 在 `case.json` 的 `supported_providers` 中添加云厂商，并在 `main.tf` 中添加对应的资源定义。

### Q: 可以混合使用基础模板和预定义模板吗？

A: 可以。它们是独立的，互不影响。

## 贡献

欢迎贡献新的基础模板！请确保：
1. 遵循上述结构
2. 提供完整的文档
3. 在多个云厂商上测试
4. 提交 Pull Request
