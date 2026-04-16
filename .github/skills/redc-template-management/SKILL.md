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
├── README.md       ← Documentation (REQUIRED)
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
└── userdata        ← The script file (no extension)
```

For **compose** templates:
```
stack-name/
├── case.json
├── README.md
└── redc-compose.yaml
```

### Step 3: Write case.json

This is the most important file — the redc engine and CI both validate it strictly.

**Required fields** (CI will fail without these):

```json
{
  "name": "scene-name",
  "user": "author-name",
  "version": "1.0.0",
  "description": "中文描述，清晰说明场景用途和关键特性",
  "description_en": "English description of the scenario",
  "tags": ["relevant", "tags"],
  "template": "preset"
}
```

**Optional fields** by template type:

For preset templates:
```json
{
  "arch": "x86_64",
  "redc_plugins": "redc-plugin-clash-config,redc-plugin-upload-r2"
}
```

For userdata templates, add:
```json
{
  "nameZh": "中文名称",
  "type": "bash",
  "category": "basic"
}
```

`type` is `bash` or `powershell`. `category` values: `basic`, `tool`, `service`, `security`.

**Version numbering**: Use semantic versioning (`major.minor.patch`). Bump patch for fixes, minor for new features, major for breaking changes.

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

### Step 5: Write README.md

Every README should include:

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

Also verify case.json has all 6 required fields: `name`, `user`, `version`, `description`, `description_en`, `tags`.

Clean up before committing: remove `.terraform/`, `.terraform.lock.hcl`, and any `*.tfstate*` files.

## Maintaining Existing Templates

### Updating a template

1. **Bump the version** in `case.json` (patch for fixes, minor for features)
2. Make the changes to `.tf` files
3. Update `README.md` if the interface changed
4. Run `terraform fmt .` and `terraform validate`

### Common maintenance tasks

**Updating provider version**: Change `version` in `versions.tf`, run `terraform init -upgrade` to verify compatibility, update the lock file.

**Adding a variable**: Add to `variables.tf` with a default value (backward-compatible), reference in `main.tf`, document in `README.md`.

**Fixing output names**: When standardizing from `ecs_ip` → `public_ip`, keep both outputs during transition (old one with a deprecation comment).

### CI Validation Rules

The GitHub Actions CI (`validate.yml`) checks:

1. **Every template directory** must have `README.md` and `case.json`
2. **case.json required fields**: `name`, `user`, `version`, `description`, `description_en`, `tags`
3. **Field constraints**: `name`/`user`/`description`/`description_en` must be non-empty strings, `version` must be a string, `tags` must be a non-empty list
4. **Terraform syntax**: `terraform fmt` must pass (syntax only, not formatting style)
5. Directories in `plugins/`, `.git/`, `.github/` are excluded from checks

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
