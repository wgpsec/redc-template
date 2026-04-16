---
name: AWS Security Hardening
description: AWS security hardening guide for red team infrastructure. Use this skill whenever the user is deploying to AWS, configuring IAM policies, setting up VPCs or security groups, asking about SSH access, encryption, key rotation, or any AWS security question. Also apply when the user mentions EC2 instances, EBS volumes, S3 buckets, or AWS networking — even if they don't explicitly ask about "security", because every AWS deployment should follow these hardening practices by default.
tags: aws, security, iam, vpc, hardening, ec2, ssh, encryption, sg
---

# AWS Security Hardening for Red Team Infrastructure

Red team infrastructure on AWS has a unique threat model: it needs to be functional enough for operations, hardened enough that it doesn't get hijacked by other threat actors, and disposable enough to tear down without leaving traces. This skill covers the security practices that matter most in this context.

## IAM — Identity and Access Control

The root account is the crown jewel of your AWS setup. If it gets compromised, an attacker owns everything — your infrastructure, your billing, and potentially your operational security.

- Create a dedicated IAM user for RedC operations. Never use the root account for day-to-day work
- Apply least-privilege policies. Start with AWS managed policies (like `AmazonEC2FullAccess`) and narrow them down based on what RedC actually needs
- Enable MFA on all IAM users — this is the single most effective protection against credential theft
- Rotate access keys every 90 days. Set a calendar reminder because you will forget
- Use IAM roles for EC2 instances instead of embedding access keys. Roles auto-rotate credentials and the keys never appear in Terraform state files

**Example — minimal IAM policy for RedC:**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["ec2:*", "vpc:*"],
      "Resource": "*",
      "Condition": {
        "StringEquals": {"aws:RequestedRegion": ["us-east-1", "ap-northeast-1"]}
      }
    }
  ]
}
```
This restricts operations to specific regions, limiting blast radius if credentials leak.

## VPC and Network Architecture

The default VPC is convenient but dangerous — everything in it is publicly accessible by default, and you share it with every other service in the account.

- Deploy instances in a dedicated VPC. This gives you full control over routing, DNS, and network ACLs
- Use private subnets for internal resources and a NAT gateway for outbound-only internet access
- Restrict SSH (port 22) in security groups to your specific IP or VPN CIDR — opening `0.0.0.0/0` means your instance will face automated brute-force attempts within minutes of launch
- Enable VPC Flow Logs for network audit trail. These help you understand what traffic is hitting your infrastructure and can reveal unauthorized access attempts

**Example — security group for a red team operator:**
```hcl
resource "aws_security_group" "operator" {
  name_prefix = "redc-operator-"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.operator_ip]  # Your IP only
    description = "SSH from operator"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }
}
```

## Instance Security

Every instance is a potential entry point. Harden them at launch time because you probably won't go back and do it later.

- Use the latest AMIs — Ubuntu 22.04 LTS is recommended for cross-tool compatibility
- Enable EBS encryption at the account level (Settings → EBS encryption → Always encrypt). This is free and protects data at rest without any code changes
- Use SSH key pairs exclusively; disable password authentication in `sshd_config` via user_data
- Run `apt update && apt upgrade -y` on first boot via user_data to patch known vulnerabilities immediately

## Cleanup and Operational Hygiene

Forgotten infrastructure is a liability — it costs money, expands your attack surface, and can hold evidence of operations.

- Use RedC's scheduled task feature to set auto-destroy schedules. If an engagement runs 2 weeks, set destruction for day 15
- Tag every resource with `owner` (who deployed it), `purpose` (what engagement), and `expires` (when to kill it). These tags enable automated cleanup scripts
- Audit running resources weekly. Use `aws ec2 describe-instances` filtered by your tags, or RedC's `list_cases` to check
- Enable AWS Config rules to detect non-compliant resources (e.g., unencrypted volumes, public S3 buckets)
