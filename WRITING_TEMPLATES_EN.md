# redc-template Template Authoring Guide (English)

This guide shows how to write templates for the redc engine https://github.com/wgpsec/redc following this repository's conventions. Works across multiple clouds (Alibaba Cloud, AWS, Tencent Cloud, etc.). Example references:
- AWS generic scene: [aws/ec2](aws/ec2)
- Alibaba Cloud proxy scene: [aliyun/proxy](aliyun/proxy)

## Template Types

redc supports four template types, distinguished by the `template` field in `case.json`:

| Type | template Value | Directory | Usage |
|------|---------------|-----------|-------|
| Preset Template | `preset` or omit | `aliyun/`, `aws/`, `tencent/`, etc. | Used in Scene Management |
| Base Template | `base` | `base-templates/` | Used in Custom Deployment |
| Userdata Template | `userdata` | `userdata-templates/` | Used in Custom Deployment and Special Modules |
| Compose Template | `compose` | `compose-templates/` | Used in Compose Management |

### case.json Template Type Examples

**Preset Template** (default, can be omitted):
```json
{
  "name": "ecs",
  "description": "Alibaba Cloud ECS Instance",
  "version": "1.0.0",
  "user": "redc",
  "provider": "alicloud"
}
```

**Base Template**:
```json
{
  "name": "alicloud-ecs",
  "description": "Alibaba Cloud ECS Instance",
  "version": "1.0.5",
  "user": "redc",
  "provider": "alicloud",
  "template": "base"
}
```

**Userdata Template**:
```json
{
  "name": "docker-installation-bash",
  "name_zh": "Docker Installation Script",
  "type": "bash",
  "category": "basic",
  "template": "userdata",
  "script": "#!/bin/bash\n..."
}
```

**Compose Template**:
```json
{
  "name": "compose-example",
  "description": "Compose Example",
  "template": "compose"
}
```

## Directory and Naming
- Path pattern: `<cloud>/<scene>`, e.g., `aws/ec2`, `aliyun/proxy`; keep names lowercase without spaces.
- Recommended files per scene: `case.json`, `README.md`, `versions.tf`, `main.tf`, `variables.tf`, `terraform.tfvars`, `outputs.tf`, `deploy.sh` (optional).

## File Conventions
- `case.json`
  - Fields: `name`, `user`, `version`, `description`; if redc modules are needed, add `redc_module`, e.g., `gen_clash_config,upload_r2` (see [aliyun/proxy/case.json](aliyun/proxy/case.json)).
- `README.md`
  - Document redc commands: `redc pull <path>`, `redc run <path>`, `redc status [uuid]`, `redc stop [uuid]`.
  - Highlight required manual replacements (e.g., `launch_template id`, region, keys) and common failure causes (see [aws/ec2/README.md](aws/ec2/README.md)).
- `versions.tf`
  - Pin provider versions to avoid compatibility issues (sample: [aws/ec2/versions.tf](aws/ec2/versions.tf)).
- `main.tf`
  - Define provider/region, core resources, and `user_data` bootstrap.
  - Do not hardcode secrets; inject via variables. Use `depends_on` where ordering matters.
- `variables.tf`
  - Declare all inputs with descriptions.
- `terraform.tfvars` (optional)
  - Store non-sensitive defaults (ports, filenames). Do not store AKSK/keys.
- `outputs.tf`
  - Output data redc or users need: public IP/DNS, generated filenames, storage URLs, etc. (see [aws/ec2/outputs.tf](aws/ec2/outputs.tf)).
- `deploy.sh` (optional)
  - Provide `-init/-start/-stop/-status` wrapping `terraform init/apply/destroy/output` for standalone use (see [aws/ec2/deploy.sh](aws/ec2/deploy.sh)).

## redc Integration Notes
- Scene path equals redc command argument: `redc pull aliyun/proxy`, `redc run aws/ec2`.
- For extra automation (e.g., generate Clash config, upload to R2), set `redc_module` in `case.json` and expose needed vars/outputs in Terraform.
- For mainland/China use cases, runtime assets can be fetched via `github_proxy` links defined in the template; for overseas use, direct GitHub links are fine. Execution artifacts can be uploaded via redc's `upload_r2` module.

## Suggested Authoring Flow
1) Create `cloud/scene` directory and add the file skeleton.
2) Write `main.tf` and `variables.tf`; ensure `terraform init` succeeds locally.
3) Write `README.md`, stressing required/optional parameters and common issues.
4) Add `outputs.tf` so redc can read key data.
5) If scripting is desired, write `deploy.sh` and keep it aligned with README (optional).
6) Local validation: `terraform validate`, then trial `terraform apply -auto-approve` with test account/low spec; confirm destroy works.

## Best Practices and Cautions
- Region/instance type: pick a default region and note alternatives; warn users to switch AZ/instance type if sold out.
- Security groups: ensure necessary ports are open; call out any public-access dependency.
- Bootstrap: `user_data` should install required tools and networking tweaks; if blocking metadata, adjust firewall accordingly (see [aws/ec2/main.tf](aws/ec2/main.tf)).
- Resource naming: short and distinctive to avoid conflicts with user resources.
- Secrets: never commit AKSK, SSH private keys, or passwords; inject via variables.
- Compatibility: if you rely on specific provider/Terraform versions or features, note them in README; keep Terraform version aligned with the repo baseline.

## Troubleshooting Checklist
- Launch fails: ensure required params replaced (e.g., launch_template id), no API timeouts, instance type not sold out, security group allows access.
- Missing outputs: confirm names in `outputs.tf` match resources in `main.tf` and are referenced after creation.
- User data errors: add basic logging in `user_data`, or check cloud console boot logs.

## Submission Checklist
- Local tests pass; remove junk (e.g., `.terraform`).
- README/scripts match actual parameters.
- Before commit: run `terraform validate`, verify `case.json` version bump, and paths/commands in README are correct.
