# redc-template Repository Instructions

## Repository Overview

This is a Terraform template repository for the [redc engine](https://github.com/wgpsec/redc). It contains infrastructure-as-code templates for deploying various scenarios across multiple cloud providers (Alibaba Cloud, AWS, Tencent Cloud, Vultr, and Volcano Engine).

**Repository Type**: Multi-cloud Terraform template collection  
**Primary Language**: HCL (Terraform)  
**Size**: Small to medium, organized by cloud provider  
**Target Runtime**: Terraform (latest version)

## Project Structure

### Directory Organization

```
├── .github/               # GitHub configuration and workflows
│   ├── workflows/         # CI/CD pipelines
│   └── ISSUE_TEMPLATE/    # Issue templates
├── aliyun/                # Alibaba Cloud templates
├── aws/                   # Amazon Web Services templates
├── tencent/               # Tencent Cloud templates
├── volcengine/            # Volcano Engine templates
├── vultr/                 # Vultr Cloud templates
├── img/                   # Documentation images
├── index.html             # Repository website/index page
├── README.md              # English documentation
├── README_CN.md           # Chinese documentation
├── WRITING_TEMPLATES_EN.md # Template authoring guide (English)
└── WRITING_TEMPLATES_CN.md # Template authoring guide (Chinese)
```

### Template Structure

Each cloud provider directory contains scenario-based subdirectories following the pattern `<cloud>/<scene>`. Each template scenario includes:

**Required Files:**
- `case.json` - Metadata with fields: `name`, `user`, `version`, `description`; optionally `redc_module`
- `README.md` - Usage instructions and documentation (MUST be uppercase)
- `main.tf` - Primary Terraform resource definitions
- `variables.tf` - Variable declarations
- `versions.tf` - Provider version constraints
- `outputs.tf` - Output definitions

**Optional Files:**
- `terraform.tfvars` - Non-sensitive default values
- `deploy.sh` - Standalone deployment script with `-init/-start/-stop/-status` flags

## Building and Validation

### Prerequisites

- Python 3 (for validation scripts)
- Terraform (latest version recommended)
- Cloud provider credentials (AKSK) for testing

### Validation Commands

**ALWAYS run validation before committing:**

The validation script is embedded in `.github/workflows/validate.yml`. To run it locally, copy the Python script from the workflow file and execute it, or push to a branch to trigger the CI validation.

The validation checks:
1. **README.md existence** - MUST be uppercase, not lowercase
2. **case.json structure** - Required fields: `name`, `user`, `version`, `description` (all lowercase)
3. **Terraform validation** - Runs `terraform fmt -write=false -recursive` which validates both syntax and formatting (does not modify files, only reports errors for unparseable syntax)

### Terraform Commands

For individual templates:

```bash
cd <cloud>/<scene>

# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Format check (validates syntax and formatting, does not modify files)
terraform fmt -write=false -recursive .

# Plan deployment (requires cloud credentials)
terraform plan

# Apply (requires cloud credentials)
terraform apply -auto-approve

# Destroy resources
terraform destroy -auto-approve
```

**Note**: Full terraform apply/destroy requires valid cloud provider credentials and should only be done in test environments.

## CI/CD Workflows

### Validation Pipeline (.github/workflows/validate.yml)

**Triggers**: Push to master, Pull requests to master (excludes `public/**` and `index.html`)

**Checks**:
1. README.md exists and is properly capitalized
2. case.json exists with all required fields (name, user, version, description)
3. Field validation (non-empty strings, version must be string type)
4. Terraform syntax validation (ignores formatting)

**Common Validation Failures**:
- Lowercase `readme.md` instead of `README.md`
- Missing or empty required fields in case.json
- Legacy `DESCRIPTION` key instead of lowercase `description`
- Version field as number instead of string (must be "1.0.1" not 1.0.1)
- Terraform syntax errors

### Secret Scanning Pipeline (.github/workflows/secret-scan.yml)

**Triggers**: Push to master, Pull requests to master, Manual dispatch

**Tool**: TruffleHog v3.82.13

**Purpose**: Detects access keys (AK), secret keys (SK), passwords, and API tokens

**Configuration**: Uses `.trufflehogignore` to exclude specific paths

⚠️ **CRITICAL**: Never commit real credentials. CI fails and blocks merging when secrets are detected.

### Push Templates Pipeline (.github/workflows/push-redc-templates.yml)

Handles synchronization with the redc engine (deployment-related).

## Template Writing Conventions

### case.json Structure

```json
{
    "name": "template-name",
    "user": "author-name",
    "version": "1.0.0",
    "description": "Template description",
    "redc_module": "gen_clash_config,upload_r2"
}
```

**Important**:
- All keys must be lowercase
- `version` must be a string, not a number
- `redc_module` is optional, used for additional automation

### Terraform Best Practices

1. **No hardcoded secrets** - Use variables for sensitive data
2. **Provider versions** - Pin versions in `versions.tf` to avoid compatibility issues
3. **Resource naming** - Keep names short and distinctive
4. **Security groups** - Ensure necessary ports are open; document public-access dependencies
5. **User data/bootstrap** - Include logging for debugging; document in README
6. **Region/instance types** - Pick reasonable defaults; warn about availability issues
7. **Dependencies** - Use `depends_on` where resource ordering matters

### README Requirements

Each template README.md should include:
- `redc` command examples: `redc pull <path>`, `redc run <path>`, `redc status [uuid]`, `redc stop [uuid]`
- Required manual replacements (launch_template id, region, keys)
- Common failure causes and troubleshooting
- Prerequisites and cloud-specific requirements

### deploy.sh Script (Optional)

If provided, must support:
- `-init` - Initialize Terraform
- `-start` - Apply configuration
- `-stop` - Destroy resources
- `-status` - Show outputs

## Key Configuration Files

### Root Level
- `.gitignore` - Excludes `.terraform/`, `*.tfstate`, `*.tfvars` with secrets
- `.trufflehogignore` - TruffleHog exclusions for secret scanning
- `.gitattributes` - Git attributes configuration

### GitHub Actions
- All workflows are in `.github/workflows/`
- Validation is mandatory for all PRs and must pass before merge

## Integration with redc Engine

Templates integrate with the redc tool (https://github.com/wgpsec/redc):
- Scene path equals redc command argument: `redc pull aliyun/proxy`, `redc run aws/ec2`
- Templates can use redc modules via `redc_module` field in case.json
- Common modules: `gen_clash_config`, `upload_r2`
- Runtime assets fetched via `github_proxy` links for mainland China; direct links for overseas
- Execution artifacts uploaded via redc's `upload_r2` module

## Common Pitfalls and Solutions

1. **README.md casing**: Must be uppercase `README.md`, not `readme.md`
2. **case.json field names**: Must be lowercase (`description`, not `DESCRIPTION`)
3. **Version field type**: Must be string "1.0.1", not number 1.0.1
4. **Empty required fields**: All required fields must have non-empty values
5. **Terraform state files**: Never commit `.tfstate` files (in .gitignore)
6. **Cloud credentials**: Never commit AKSK, passwords, or SSH keys
7. **Launch template IDs**: AWS templates require manual replacement of launch_template id
8. **Instance type availability**: May need to switch regions/AZs if instance types are sold out

## Working with This Repository

### Adding a New Template

1. Create directory: `<cloud>/<scene>`
2. Add all required files (case.json, README.md, main.tf, variables.tf, versions.tf, outputs.tf)
3. Write main.tf and ensure `terraform init` succeeds locally
4. Write README.md with required parameters and common issues
5. Add outputs.tf for redc integration
6. Optional: Add deploy.sh for standalone use
7. Validate locally: `terraform validate`
8. Test with low-spec resources: `terraform apply -auto-approve`
9. Verify cleanup: `terraform destroy -auto-approve`
10. Run validation script before committing

### Modifying Existing Templates

1. Update version in case.json (bump version number)
2. Make minimal changes to Terraform files
3. Update README.md if usage changes
4. Run `terraform validate` to check syntax
5. Test changes in isolated environment if possible
6. Run validation script before committing

### Testing Changes

- Individual template testing requires cloud provider credentials
- Use test accounts with appropriate permissions
- Start with smallest/cheapest instance types
- Always clean up resources after testing with `terraform destroy`
- Validation script can run without cloud credentials (syntax checks only)

## File Exclusions

The following are excluded from version control:
- `.terraform/` directories
- `*.tfstate` and `*.tfstate.backup` files
- `.terraform.lock.hcl` files
- Any `*.tfvars` files containing secrets
- Build artifacts in `public/` directory

## Documentation

- **English**: README.md, WRITING_TEMPLATES_EN.md
- **Chinese**: README_CN.md, WRITING_TEMPLATES_CN.md
- Template writing guide provides comprehensive authoring instructions
- Each template has its own README.md with specific usage instructions
