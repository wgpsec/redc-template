---
name: Multi-Cloud Deployment
description: Guide for deploying infrastructure across multiple cloud providers (AWS, Azure, GCP, Alibaba Cloud, Tencent Cloud, Huawei Cloud, Volcengine). Use this skill whenever the user mentions deploying to more than one cloud, comparing cloud providers, selecting regions, configuring provider credentials, or asking about cross-cloud compatibility. Also use when the user asks about a specific Chinese cloud provider (Alibaba, Tencent, Huawei, Volcengine) since these have unique authentication patterns that differ from Western clouds.
tags: multi-cloud, aws, azure, gcp, aliyun, tencentcloud, huaweicloud, volcengine, region, credential, provider
---

# Multi-Cloud Deployment Guide

RedC's core strength is deploying infrastructure across multiple clouds simultaneously. This skill covers the practical knowledge needed to work across providers — from authentication setup to region selection to cross-cloud consistency patterns. Understanding these differences matters because each cloud has its own authentication model, naming conventions, and regional availability, and getting any of these wrong means a deployment that fails at plan time.

## Provider Authentication

Each cloud provider authenticates differently. Set these environment variables before running RedC, or configure them in RedC's credential profiles.

| Provider | Required Environment Variables | Notes |
|----------|-------------------------------|-------|
| **AWS** | `AWS_ACCESS_KEY_ID` + `AWS_SECRET_ACCESS_KEY` | Or use `~/.aws/credentials` profile |
| **Azure** | `ARM_SUBSCRIPTION_ID` + `ARM_TENANT_ID` + `ARM_CLIENT_ID` + `ARM_CLIENT_SECRET` | Service principal recommended |
| **GCP** | `GOOGLE_APPLICATION_CREDENTIALS` (path to JSON) | Service account key file |
| **Alibaba Cloud** | `ALICLOUD_ACCESS_KEY` + `ALICLOUD_SECRET_KEY` | China mainland requires real-name verification |
| **Tencent Cloud** | `TENCENTCLOUD_SECRET_ID` + `TENCENTCLOUD_SECRET_KEY` | SecretId, not AccessKey |
| **Huawei Cloud** | `HW_ACCESS_KEY` + `HW_SECRET_KEY` | Regional endpoints differ from global |
| **Volcengine** | `VOLCENGINE_ACCESS_KEY` + `VOLCENGINE_SECRET_KEY` | ByteDance cloud platform |

Note the naming inconsistency — AWS uses "access key", Tencent uses "secret id", GCP uses a JSON file. This is a common source of confusion. When helping users configure credentials, pay attention to which provider they're targeting.

## Region Selection Strategy

Region choice affects latency, cost, data residency, and instance availability. Pick based on your primary constraint:

**Proximity to target** (red team operations):
Choose the region geographically closest to the target network. A C2 server in `ap-northeast-1` (Tokyo) communicating with targets in Japan will have much lower latency than one in `us-east-1`.

**Cost minimization:**
- AWS: `us-east-1` (N. Virginia) is almost always cheapest
- Azure: `eastus` has the widest instance selection and lowest pricing
- GCP: `us-central1` (Iowa) offers the best spot pricing
- Chinese clouds: `cn-hangzhou` (Alibaba), `ap-guangzhou` (Tencent) are the primary regions with best availability

**High availability:**
Distribute across 2+ regions in the same provider, or across providers. RedC's multi-cloud templates make this straightforward.

## Cross-Cloud Consistency

When deploying the same tool across multiple clouds, standardize these elements to reduce operational complexity:

- **OS**: Use Ubuntu 22.04 LTS everywhere. It's available on all providers and most red team tools support it
- **Init scripts**: Use cloud-init / `user_data` for post-deploy configuration. The syntax is identical across providers
- **Naming conventions**: Use a consistent prefix like `redc-{project}-{provider}-{role}` so you can identify resources at a glance
- **Instance sizing**: Each provider has different naming, but roughly equivalent tiers:

| Size | AWS | Azure | GCP | Alibaba |
|------|-----|-------|-----|---------|
| Small (2c/4G) | `t3.medium` | `B2s` | `e2-medium` | `ecs.t6-c1m2.large` |
| Medium (4c/8G) | `t3.xlarge` | `B4ms` | `e2-standard-4` | `ecs.g6.xlarge` |

## Cost Control Across Clouds

Multi-cloud deployments multiply cost risk because you need to track spending across separate billing dashboards.

- Use spot/preemptible instances for non-critical workloads (scanning, data processing)
- Set billing alerts on every cloud account — a forgotten instance in one provider can silently drain budget
- Use RedC's `get_balances` tool to check all accounts at once
- Use RedC's scheduled task feature for auto-shutdown when engagements end
