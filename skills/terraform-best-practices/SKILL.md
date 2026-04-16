---
name: Terraform Best Practices
description: Terraform IaC best practices for cloud infrastructure deployments. Use this skill whenever the user is writing Terraform code, creating templates, generating .tf files, asking about state management, modules, variables, security groups, or any infrastructure-as-code question. Also use when reviewing or debugging Terraform configurations, discussing provider setup, or planning multi-resource deployments — even if the user doesn't explicitly mention "Terraform" but is clearly working with .tf files or HCL syntax.
tags: terraform, iac, best-practices, state, module, hcl, provider, variable, security
---

# Terraform Best Practices

This skill provides guidance for writing reliable, secure Terraform configurations in RedC deployment scenarios. The recommendations here come from real-world experience with multi-cloud red team infrastructure — where a misconfigured state file or leaked credential can compromise an entire operation.

## State Management

Use remote state because local state files are a single point of failure. If the file gets deleted, corrupted, or conflicts with another operator's changes, you lose track of what's deployed — which in red team scenarios means orphaned infrastructure you're still paying for.

- Store state in cloud-native backends (S3+DynamoDB for AWS, OSS for Alibaba, COS for Tencent)
- Enable state locking to prevent two operators from applying simultaneously
- Keep `.tfstate` out of version control — it often contains sensitive outputs like IP addresses and credentials
- Separate state per environment (dev/staging/prod) so a bad apply in dev doesn't corrupt prod state

**Example — remote backend configuration:**
```hcl
terraform {
  backend "s3" {
    bucket         = "myteam-tfstate"
    key            = "prod/infra.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tf-lock"
    encrypt        = true
  }
}
```

## Module Design

Modules keep configurations DRY and composable. A well-designed module encapsulates one concern (e.g., "a VPC with public/private subnets") so you can reuse it across deployments without copy-pasting.

- Keep each module focused on a single responsibility — a "vpc" module shouldn't also create EC2 instances
- Use `validation` blocks on variables to catch bad input before plan time
- Output the values downstream resources need (IDs, IPs, endpoints, DNS names)
- Pin module versions in production (`source = "git::...?ref=v1.2.0"`) to avoid surprise changes

**Example — variable validation:**
```hcl
variable "instance_type" {
  type        = string
  description = "EC2 instance type for the deployment"
  default     = "t3.small"
  validation {
    condition     = can(regex("^(t3|t4g|m5|c5)\\.", var.instance_type))
    error_message = "Use t3, t4g, m5, or c5 family instances for red team workloads."
  }
}
```

## Security

Red team infrastructure is high-value target material. A leaked credential or overly permissive security group doesn't just cost money — it can expose your operation.

- Never hardcode credentials in `.tf` files. Use environment variables (`TF_VAR_*`), a secrets manager, or RedC's profile-based credential injection
- Restrict security group ingress to the CIDRs you actually need. Opening `0.0.0.0/0` on port 22 invites scanners within minutes
- Enable encryption at rest for all storage resources (EBS, S3, disks) — it's usually free and prevents data exposure on decommission
- Prefer IAM roles attached to instances over embedding access keys, because roles auto-rotate and don't appear in state files
- Tag every resource with `owner`, `purpose`, and `expires` so forgotten infrastructure can be identified and cleaned up

## Variables and Locals

Good variable hygiene makes templates reusable and self-documenting.

- Set sensible defaults for optional variables so users can deploy with minimal config
- Write a `description` for every variable — RedC's template system surfaces these to users
- Mark sensitive variables with `sensitive = true` to prevent their values from appearing in logs and plan output
- Use `locals` for computed values to avoid repeating expressions across resources

**Example — locals for computed naming:**
```hcl
locals {
  name_prefix = "${var.project}-${var.environment}"
  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "RedC"
  }
}
```

## Common Pitfalls

These are the mistakes that come up most often in RedC deployments:

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| "Could not load plugin" after adding a provider | Forgot `terraform init` | Run `terraform init -upgrade` |
| Resources created in wrong order | Missing implicit dependency | Add explicit `depends_on` |
| Plan shows unexpected changes | State drift from manual console changes | Run `terraform refresh` then review |
| Sensitive value visible in output | Forgot `sensitive = true` | Add it to the variable and output blocks |
| `-target` left partial state | Targeted apply skipped dependent resources | Apply the full plan without `-target` to reconcile |
