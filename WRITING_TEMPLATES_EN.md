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
- Recommended files per scene: `case.json`, `README.md`, `versions.tf`, `main.tf`, `variables.tf`, `terraform.tfvars`, `outputs.tf`, `deploy.sh` (optional); for preset scenes, the recommended deliverable is to provide both the Chinese `README.md` and the English `README_EN.md`.

## File Conventions
- `case.json`
  - Fields: `name`, `user`, `version`, `description`, `tags` (array of tags for categorization).
  - To bind plugins, add `redc_plugins` with comma-separated plugin names, e.g., `"redc_plugins": "redc-plugin-clash-config,redc-plugin-upload-r2"` (see [aliyun/proxy/case.json](aliyun/proxy/case.json)).
  - For plugin development, see the [Plugin Development Guide](doc/plugin-development.md).
- `README.md`
  - For preset scenes, the recommended deliverable is a Chinese `README.md` and an English `README_EN.md`; the Chinese `README.md` follows the Chinese contract headings in the Chinese guide, and `README_EN.md` follows the English contract headings below.
  - For preset scene templates, follow the Preset Scene README Contract below; keep `Quick Start` limited to the minimum runnable `redc-cli` path and keep parameter explanation in `Parameters`.
  - Highlight required manual replacements (e.g., `launch_template id`, region, keys); add troubleshooting only as needed by putting frequent failure points in `FAQ` and supplementary reminders in `Notes`.

### Preset Scene README Contract

- Scope
  - Mandatory: preset scene templates under cloud-provider scene directories
  - Reference only: `base-templates/`, `userdata-templates/`, `compose-templates/`, `plugins/`
- Recommended deliverable: provide both the Chinese `README.md` and the English `README_EN.md` for preset scenes; the Chinese `README.md` uses the Chinese contract headings from the Chinese guide, and `README_EN.md` uses the English contract headings in this section.
- Required sections, in order
  1. `Scene Description`
  2. `Prerequisites`
  3. `Quick Start`
  4. `Parameters`
- Optional sections
  - `Outputs`
  - `FAQ`
  - `Notes`
  - `Appendix`
- Hard constraints
  - Preserve heading identity exactly so downstream consumers can map sections stably.
  - Required section titles must stay exactly the same, in the exact order above, and each required heading may appear at most once.
  - Required sections use level-2 headings (`##`).
  - No other same-level headings may be inserted between the four required sections.
  - Optional sections, if used, also use level-2 headings, appear after the four required sections, use the exact standard titles listed above, and each optional heading may appear at most once.
  - `Scene Description` explains purpose, when to use it, and what the user gets after deployment.
  - `Prerequisites` lists what must be prepared or manually replaced before running.
  - `Quick Start` keeps only the minimum runnable `redc-cli` path.
  - `Parameters` explains parameter names, whether required, defaults, examples, and behavior impact.
  - Keep pre-run preparation in `Prerequisites`; keep field-level parameter explanation in `Parameters`.
  - Keep `Outputs` as a separate section when deployment outputs drive the user's next action.
  - Do not dump everything into `Notes`.
  - Architecture diagrams, design constraints, and long config examples go to `Appendix`.

### Minimal Preset Scene README Skeleton

````md
<!-- The first four sections below are required and must stay in this order. -->
## Scene Description
Explain the scene purpose, when to use it, and what the user gets after deployment.

## Prerequisites
List only pre-run requirements, including required manual replacements before execution.

## Quick Start
Keep only the minimum runnable `redc-cli` path.
```sh
redc pull <cloud>/<scene>
redc run <cloud>/<scene>
redc status [uuid]
redc stop [uuid]
```

## Parameters
Centralize parameter names, whether required, defaults, examples, and behavior impact here.

<!-- Append the sections below only when needed. -->
## Outputs
Keep this section only when deployment outputs drive the user's next action, and document the key values, access entry points, or generated artifacts here.

## FAQ
Add only frequent failure points or recurring troubleshooting items.

## Notes
Add supplementary reminders that do not fit the required sections.

## Appendix
Place architecture diagrams, design constraints, and long config examples here.
````
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
- For extra automation (e.g., generate Clash config, upload to R2, update DNS), set `redc_plugins` in `case.json` to bind the corresponding plugins. Plugins automatically execute hook scripts at key points in the scene lifecycle.
- For mainland/China use cases, runtime assets can be fetched via `github_proxy` links defined in the template; for overseas use, direct GitHub links are fine. Execution artifacts can be uploaded via the `redc-plugin-upload-r2` plugin.

## Suggested Authoring Flow
1) Create `cloud/scene` directory and add the file skeleton.
2) Write `main.tf` and `variables.tf`; ensure `terraform init` succeeds locally.
3) Write the README deliverables; for preset scenes, recommend providing both the Chinese `README.md` and the English `README_EN.md`, with each README using the contract headings for its own language; highlight required manual replacements, add `FAQ` only when there are frequent failure points, and use `Notes` only for supplementary reminders.
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
