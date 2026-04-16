---
name: Deployment Troubleshooting
description: Diagnose and fix Terraform deployment errors in RedC scenarios. Use this skill whenever the user encounters an error during deployment — whether it's a Terraform init failure, authentication error, resource creation failure, network timeout, state conflict, or cloud-init problem. Also use when the user pastes an error message, says "deployment failed", asks why something isn't working, or reports that instances are unreachable after creation. This skill covers the most common failure modes across all cloud providers supported by RedC.
tags: troubleshoot, error, debug, terraform, deploy, timeout, auth, state, cloud-init, fix
---

# Deployment Troubleshooting Guide

When a deployment fails, the error message is your best starting point — but Terraform and cloud provider error messages are often cryptic or misleading. This guide maps common error patterns to their root causes and fixes, organized by the deployment phase where they typically occur.

When helping a user debug a deployment issue, start by identifying which phase failed, then match the error text against the patterns below.

## Phase 1: Terraform Init Errors

Init failures happen before any infrastructure is created. They're usually about provider plugins or backend configuration.

| Error Pattern | Root Cause | Fix |
|---------------|-----------|-----|
| `Failed to install provider` | No internet, proxy blocking registry.terraform.io, or provider name typo | Check connectivity: `curl -I https://registry.terraform.io`. If behind proxy, set `HTTPS_PROXY`. Verify provider source string |
| `Could not load plugin` | Plugin cache corrupted or provider version mismatch | Run `terraform init -upgrade` to re-download. Delete `.terraform/` and retry if persistent |
| `Backend initialization required` | Remote state bucket doesn't exist or credentials wrong | Create the bucket first, verify credentials have access to it. Check region matches |
| `Failed to query available provider packages` | DNS resolution failure or firewall blocking | Try `nslookup registry.terraform.io`. Consider using `terraform init -plugin-dir` with pre-downloaded providers |

## Phase 2: Authentication Errors

These surface during `terraform plan` when the provider tries to validate credentials against the cloud API.

| Error Pattern | Provider | Fix |
|---------------|----------|-----|
| `NoCredentialProviders` | AWS | `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` not set or expired. Re-export them or check RedC profile |
| `AuthorizationFailed` | Azure | Service principal lacks permissions on the subscription. Verify `ARM_SUBSCRIPTION_ID` matches, check role assignments |
| `googleapi: Error 403` | GCP | Service account doesn't have required permissions. Check IAM roles in GCP Console, verify `GOOGLE_APPLICATION_CREDENTIALS` path |
| `InvalidAccessKeyId` | AWS/Alibaba | Access key deleted or rotated. Generate a new key pair in the console |
| `AuthFailure` | Tencent | `TENCENTCLOUD_SECRET_ID` wrong (note: it's "SecretId" not "AccessKey") |

**Debugging tip:** When a user reports an auth error, ask them to verify the environment variables are set in the current shell session. A common mistake is setting them in one terminal and running RedC in another.

## Phase 3: Resource Creation Failures

These happen during `terraform apply` when the cloud provider rejects a resource creation request.

| Error Pattern | Root Cause | Fix |
|---------------|-----------|-----|
| `InstanceLimitExceeded` | Account quota reached for this instance type | Request a quota increase via support ticket, or use a different instance type/region |
| `VPCLimitExceeded` | Default limit is 5 VPCs per region | Clean up unused VPCs in the console, or request a limit increase |
| `InvalidParameterValue` for instance type | Instance type not available in the selected AZ | Check availability with `aws ec2 describe-instance-type-offerings`, try a different AZ or type |
| `InsufficientInstanceCapacity` | AWS capacity constraints in that AZ | Retry in a different AZ (`-a`, `-b`, `-c`), or try a different instance family |
| `Insufficient balance` | Prepaid account ran out of credit | Top up the account. Use `get_balances` to check current balance |

## Phase 4: Network and Connectivity Issues

These typically appear after instances are created but the user can't reach them.

| Symptom | Likely Cause | Investigation Steps |
|---------|-------------|---------------------|
| SSH connection refused | Security group doesn't allow inbound SSH from user's IP | Check the security group ingress rules. Verify user's current public IP matches the allowed CIDR |
| SSH connection timed out | Instance has no public IP, or is in a private subnet without NAT | Verify the instance has a public IP in the console. Check subnet route table has an internet gateway |
| `timeout awaiting response` during apply | Security group blocks outbound HTTPS (443) | The instance needs outbound access to download packages. Check egress rules |
| Instance created but tools don't work | user_data script failed silently | SSH in and check `/var/log/cloud-init-output.log` for errors |

## Phase 5: State Issues

State problems are dangerous because they can cause Terraform to lose track of real infrastructure, leading to orphaned resources you're still paying for.

| Error Pattern | Root Cause | Fix |
|---------------|-----------|-----|
| `Error acquiring the state lock` | Another `terraform apply` is running, or a previous run crashed without releasing the lock | Wait for the other process to finish. If it crashed, force-unlock: `terraform force-unlock <LOCK_ID>` |
| `Resource already exists` | Resource was created outside Terraform (e.g., manually in console) | Import it: `terraform import <resource_address> <resource_id>` |
| `Unsupported attribute` | Provider version upgraded and the attribute name changed | Pin provider version in `required_providers`, or update your `.tf` to use the new attribute name |
| Drift between state and reality | Manual changes in cloud console | Run `terraform plan` to see the diff, then decide: apply to overwrite manual changes, or `terraform refresh` to update state |

## Phase 6: User Data and Provisioning

Cloud-init runs on first boot and its failures are silent from Terraform's perspective — the instance is "created" but not properly configured.

| Symptom | Investigation | Fix |
|---------|---------------|-----|
| Packages not installed | Check `/var/log/cloud-init-output.log` | Usually DNS or proxy issues. Add `apt update` retry logic to the script |
| Script didn't run at all | Check `/var/log/cloud-init.log` for YAML parse errors | Validate the cloud-init YAML syntax. Common issue: wrong indentation in `write_files` |
| Script timed out | Long-running operations (compiling, large downloads) | Break into smaller scripts, or increase timeout. Consider using RedC's `exec_command` for post-deploy setup instead |
| Wrong permissions on files | `write_files` defaults to root ownership | Set `owner` and `permissions` explicitly in the cloud-init config |
