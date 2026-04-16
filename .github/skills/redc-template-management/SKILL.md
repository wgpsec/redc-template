---
name: redc-template-management
description: Create, maintain, and validate redc Terraform templates for multi-cloud deployment scenarios. Use this skill whenever someone wants to add a new cloud template (ECS, EC2, VM, etc.), create a userdata script, write a compose template, update an existing template's version or configuration, fix CI validation failures, or add support for a new cloud provider. Also use when reviewing template PRs, checking case.json compliance, or standardizing output naming conventions across templates.
---

# redc Template Management

This skill guides you through creating and maintaining templates for the [redc](https://github.com/wgpsec/redc) multi-cloud deployment engine. redc templates are Terraform-based infrastructure-as-code definitions organized by cloud provider, with a metadata layer (`case.json`) that the redc engine and GUI consume.

## Template Types

redc has four template types, each in its own directory:

| Type | `template` value | Directory | When to use |
|------|-----------------|-----------|-------------|
| **Preset** | `preset` or omit | `aliyun/`, `aws/`, `tencent/`, etc. | Full cloud scenarios (ECS+VPC+SG) shown in Scene Management |
| **Base** | `base` | `base-templates/` | Minimal cloud primitives for Custom Deployment |
| **Userdata** | `userdata` | `userdata-templates/` | Init scripts (bash/powershell) composable with any base |
| **Compose** | `compose` | `compose-templates/` | Docker Compose definitions for Compose Management |

Pick **preset** for self-contained "one-click deploy" scenarios. Pick **base** when providing a minimal building block that users combine with userdata scripts. Pick **userdata** for software installation scripts. Pick **compose** for Docker service stacks.

## Creating a New Template

### Step 1: Determine the template type and location

**Preset template** → `<provider>/<scene-name>/` (e.g., `aliyun/nat-probe/`, `aws/proxy/`)
**Base template** → `base-templates/<provider>-<resource>/` (e.g., `base-templates/aws-ec2/`)
**Userdata template** → `userdata-templates/<name>/` (e.g., `userdata-templates/redis-bash/`)
**Compose template** → `compose-templates/<name>/` (e.g., `compose-templates/elk-stack/`)

Directory and file names: lowercase, hyphens for word separation, no spaces.

### Step 2: Create the required files

Every template directory needs at minimum:

```
scene-name/
├── case.json       ← Metadata (REQUIRED)
├── README.md       ← Documentation in Chinese (REQUIRED)
├── README_EN.md    ← Documentation in English (REQUIRED)
├── versions.tf     ← Provider version locks (preset/base only)
├── main.tf         ← Core resources (preset/base only)
├── variables.tf    ← Input variables (preset/base only)
└── outputs.tf      ← Output values (preset/base only)
```

For **userdata** templates, the structure is simpler:
```
script-name/
├── case.json
├── README.md
├── README_EN.md
└── userdata        ← The script file (no extension)
```

For **compose** templates:
```
stack-name/
├── case.json
├── README.md
├── README_EN.md
└── redc-compose.yaml
```

### Step 3: Write case.json

This is the most important file — the redc engine and CI both validate it strictly.

**Common required fields** (all template types, CI will fail without these):

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | 模板名称，非空 |
| `user` | string | 作者名，非空 |
| `version` | string | 语义化版本号，如 `"1.0.0"` |
| `description` | string | 中文描述，非空 |
| `description_en` | string | 英文描述，非空 |
| `tags` | list | 标签列表，非空 |

**Type-specific required fields** (CI also enforces these):

| Template Type | Extra Required Fields | Description |
|---------------|----------------------|-------------|
| `preset` | `arch` | 架构，如 `"x86_64"` 或 `"arm64"` |
| `base` | `arch`, `provider` | 架构 + 云厂商标识（如 `"alicloud"`, `"aws"`） |
| `userdata` | `nameZh`, `type`, `category` | 中文名 + 脚本类型 (`bash`/`powershell`) + 分类 (`basic`/`tool`/`service`/`security`) |
| `compose` | (无额外字段) | — |

**Preset template example**:
```json
{
  "name": "ecs",
  "user": "redc",
  "version": "1.0.0",
  "description": "阿里云 ECS 实例",
  "description_en": "Alibaba Cloud ECS instance",
  "tags": ["ecs", "basic"],
  "arch": "x86_64",
  "template": "preset"
}
```

**Base template example**:
```json
{
  "name": "alicloud-ecs",
  "user": "redc",
  "version": "1.0.5",
  "description": "阿里云 ECS 基础模板",
  "description_en": "Alibaba Cloud ECS base template",
  "tags": ["ecs"],
  "arch": "x86_64",
  "provider": "alicloud",
  "template": "base"
}
```

**Userdata template example**:
```json
{
  "name": "f8x-bash",
  "nameZh": "f8x 渗透测试工具集",
  "user": "r0fus0d",
  "version": "1.0.1",
  "description": "f8x 渗透测试工具集",
  "description_en": "f8x penetration testing toolkit",
  "tags": ["tool"],
  "type": "bash",
  "category": "tool",
  "template": "userdata"
}
```

**Optional fields** (not enforced by CI, but useful):

| Field | Used by | Description |
|-------|---------|-------------|
| `redc_plugins` | preset | 逗号分隔的插件列表 |
| `provider` | preset | 云厂商标识（preset 可选，base 必填） |
| `vulType` | userdata | 漏洞类型（安全类 userdata） |
| `cveId` | userdata | CVE 编号 |

**Version numbering**: Use semantic versioning (`major.minor.patch`). Bump patch for fixes, minor for new features, major for breaking changes. **Every template change must bump the version** — redc uses this field to detect updates; unchanged versions will not trigger `redc pull` updates on user machines.

### Step 4: Write Terraform files (preset/base templates)

#### versions.tf

Lock the provider version to avoid compatibility surprises:

```hcl
terraform {
  required_providers {
    alicloud = {
      source  = "aliyun/alicloud"
      version = "1.241.0"
    }
  }
}

provider "alicloud" {
  profile = "cloud-tool"
  region  = var.region
}
```

Current provider versions in use across the repo:
- `aliyun/alicloud`: `1.241.0`
- `hashicorp/aws`: `5.25.0`
- `tencentcloudstack/tencentcloud`: `1.81.8`
- `hashicorp/azurerm`: `4.61.0`
- `volcengine/volcengine`: `0.0.184`

When adding a template for an existing provider, match the version already used unless there's a specific reason to differ.

#### variables.tf

Declare all configurable inputs. Common patterns:

```hcl
variable "region" {
  type        = string
  description = "Cloud region"
  default     = "cn-beijing"
}

variable "instance_name" {
  type        = string
  description = "Instance name"
  default     = "my-scene"
}

variable "instance_password" {
  type        = string
  description = "Login password (leave empty to auto-generate)"
  sensitive   = true
  default     = ""
}
```

Hardcoded AMIs/image IDs and regions are a common template smell — extract them to variables with sensible defaults so users can override them.

#### main.tf

The core resource definitions. Follow these patterns:

**Password auto-generation** (standard pattern used across all templates):
```hcl
locals {
  password_seed      = replace(uuid(), "-", "")
  generated_password = format("%s_+%s", substr(local.password_seed, 0, 12), substr(local.password_seed, 12, 10))
  instance_password  = var.instance_password != "" ? var.instance_password : local.generated_password
}
```

**User data script**: Inline with `<<-EOF` heredoc. Always include:
1. Basic packages: `curl`, `wget`, `tmux`, `unzip`
2. BBR network optimization
3. Cloud agent removal (for Chinese clouds)
4. trzsz for terminal file transfer

**Security groups**: Open all TCP/UDP for lab/pentest use. Add a comment noting this is intentional.

**Naming**: Use `var.instance_name` prefix for all resource names to avoid collisions.

#### outputs.tf

The redc engine and GUI read these outputs. Use these **standardized names**:

| Output | Description | Use when |
|--------|-------------|----------|
| `public_ip` | Instance public IP | Always (if instance has public IP) |
| `ssh_user` | SSH username | Always |
| `ssh_command` | Full SSH command | Always |
| `ssh_password` | Instance password (nonsensitive) | Password-based auth |
| `ssh_private_key_path` | Path to SSH key file | Key-based auth (AWS, GCP) |

**Legacy names** (`ecs_ip`, `ecs_password`) still work but prefer the standardized names for new templates.

```hcl
output "public_ip" {
  description = "Public IP address"
  value       = alicloud_instance.ecs.public_ip
}

output "ssh_user" {
  description = "SSH login username"
  value       = "root"
}

output "ssh_command" {
  description = "SSH connection command"
  value       = "ssh root@${alicloud_instance.ecs.public_ip}"
}

output "ssh_password" {
  description = "SSH password"
  value       = nonsensitive(local.instance_password)
}
```

### Step 5: Write README.md and README_EN.md

Every template must have both a Chinese README (`README.md`) and an English README (`README_EN.md`). The redc website uses `README_EN.md` when users browse in English mode, so both files are required by CI.

Both READMEs should include:

1. **Title and description** — What this template deploys
2. **Architecture diagram** (for complex setups) — ASCII art showing resource relationships
3. **Usage section** — Both `redc` commands and standalone `terraform` commands
4. **Variables table** — All configurable parameters with defaults
5. **Outputs table** — What information is returned after deployment
6. **Notes/caveats** — Cost warnings, region restrictions, security implications

Template:

```markdown
# Scene Name

Brief description of what gets deployed.

## Usage

### Via redc

\```bash
redc pull <provider>/<scene>
redc run <provider>/<scene>
redc status
redc stop
\```

### Standalone

\```bash
terraform init
terraform apply -auto-approve
terraform destroy -auto-approve
\```

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `region` | `cn-beijing` | Cloud region |

## Outputs

| Output | Description |
|--------|-------------|
| `public_ip` | Instance public IP |
```

### Step 6: Validate

Before committing, run these checks:

```bash
# Format check
terraform fmt -check .

# Syntax validation
terraform init -backend=false
terraform validate

# Auto-fix formatting
terraform fmt .
```

Also verify case.json has all required fields — both the 6 common fields (`name`, `user`, `version`, `description`, `description_en`, `tags`) and the type-specific fields:
- **preset**: `arch`
- **base**: `arch`, `provider`
- **userdata**: `nameZh`, `type`, `category`

Clean up before committing: remove `.terraform/`, `.terraform.lock.hcl`, and any `*.tfstate*` files.

## Maintaining Existing Templates

### Updating a template

> **⚠️ 重要**: 任何场景模板的更新（包括 .tf 文件、README、case.json 字段修改等），都**必须**同时更新 `case.json` 中的 `version` 字段。redc 工具通过版本号判断模板是否有更新，如果版本号不变，用户端的 `redc pull` 不会拉取到最新模板。

1. **Bump the version** in `case.json` — patch for fixes (1.0.1→1.0.2), minor for features (1.0.x→1.1.0)
2. Make the changes to `.tf` files
3. Update `README.md` if the interface changed
4. Run `terraform fmt .` and `terraform validate`

### Common maintenance tasks

**Updating provider version**: Change `version` in `versions.tf`, run `terraform init -upgrade` to verify compatibility, update the lock file.

**Adding a variable**: Add to `variables.tf` with a default value (backward-compatible), reference in `main.tf`, document in `README.md`.

**Fixing output names**: When standardizing from `ecs_ip` → `public_ip`, keep both outputs during transition (old one with a deprecation comment).

### CI Validation Rules

The GitHub Actions CI (`validate.yml`) checks:

1. **Every template directory** must have `README.md`, `README_EN.md` and `case.json`
2. **Common required fields**: `name`, `user`, `version`, `description`, `description_en`, `tags`
3. **Type-specific required fields**:
   - `preset`: `arch`
   - `base`: `arch`, `provider`
   - `userdata`: `nameZh`, `type`, `category`
   - `compose`: (no extra fields)
4. **Field constraints**: `name`/`user`/`description`/`description_en` must be non-empty strings, `version` must be a string, `tags` must be a non-empty list
5. **Terraform syntax**: `terraform fmt` must pass (syntax only, not formatting style)
6. Directories in `plugins/`, `.git/`, `.github/` are excluded from checks

### Adding a new cloud provider

1. Create the provider directory at repo root (e.g., `oracle/`)
2. Add at least one template (e.g., `oracle/compute/`)
3. Follow existing patterns — look at `aliyun/ecs/` or `aws/ec2/` as reference
4. Update `README.md` at repo root to list the new provider
5. Optionally add a base template in `base-templates/<provider>-<resource>/`

## Reference: Cloud Provider Patterns

### Alibaba Cloud (aliyun/)
- Provider: `aliyun/alicloud`
- Auth: `profile = "cloud-tool"` (redc manages credentials)
- Network: VPC + VSwitch + Security Group
- Instance: `alicloud_instance` with `internet_max_bandwidth_out` for public IP
- Agent removal: wget aegis uninstall scripts
- Spot instances: `spot_strategy = "SpotWithPriceLimit"` for cost savings

### AWS (aws/)
- Provider: `hashicorp/aws`
- Auth: environment variables (redc injects)
- SSH: auto-generate via `tls_private_key` + `aws_key_pair` + `local_file`
- Instance: `aws_instance` with auto-assigned public IP via subnet
- Random suffix: `random_id.suffix.hex` for unique resource names
- Spot: `aws_spot_instance_request` for cost savings

### Tencent Cloud (tencent/)
- Provider: `tencentcloudstack/tencentcloud`
- Auth: environment variables
- Network: VPC + Subnet + Security Group
- Instance: `tencentcloud_instance`
- Output file: `output.tf` (note: singular, not `outputs.tf`)

### Azure (azure/)
- Provider: `hashicorp/azurerm`
- Auth: `features {}` block required
- Resource group required for all resources
- Network: VNet + Subnet + NSG + Public IP + NIC

## Reference: Userdata Script Patterns

Userdata scripts go in `userdata-templates/<name>/userdata` (no file extension).

**Bash template**:
```bash
#!/bin/bash
# Install <tool>
<installation commands>

echo "<tool> installed successfully!"
```

**PowerShell template**:
```powershell
# Install <tool>
<installation commands>

Write-Host "<tool> installed successfully!"
```

Keep scripts minimal and idempotent. The redc engine injects these into the `user_data` field of cloud instances.
