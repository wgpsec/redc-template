---
name: terraform-provider-docs
description: Look up official Terraform provider documentation before writing or debugging any Terraform resource, data source, or provider configuration. Use this skill whenever you encounter a Terraform error, need to write a new resource block, are unsure about argument syntax or valid values, need to check resource attribute constraints, or want to understand provider-specific behaviors. Consult the docs first instead of guessing Terraform arguments from memory — it consistently saves multiple debug cycles.
---

# Terraform Provider Documentation Lookup

## Why This Skill Exists

Terraform provider APIs have strict argument constraints that are not reliably stored in AI training data. Guessing argument values (port formats, protocol enums, attribute names, etc.) leads to repeated `terraform apply` failures. **Looking up the official docs first saves 5-10 debug cycles.**

Real example: `alicloud_forward_entry` requires port format `"1/65535"` (slash separator), not `"1-65535"` (dash). The `ip_protocol` only accepts `any`, `tcp`, `udp`, `forwardgroup` — not `TCP` or `UDP`. These details are only reliably found in the official docs.

## Core Principle

The reason this skill exists is simple: Terraform provider arguments have precise constraints (format strings, enum values, argument interdependencies) that differ between resources even within the same provider. Getting one wrong means a failed `terraform apply`, reading the error, guessing again, and repeating — often 3-5 times. A single doc lookup before writing the resource eliminates this entire cycle.

Fetch the official documentation page before writing or modifying any Terraform resource or data source. Don't rely on memory or pattern-matching from other resources — each resource has its own unique argument constraints.

## How to Look Up Docs

### Step 1: Identify the provider and resource type

From the Terraform code, extract:
- **Provider**: e.g., `alicloud`, `aws`, `azurerm`, `google`, `tencentcloud`, `volcengine`
- **Resource/Data source type**: e.g., `alicloud_forward_entry`, `aws_instance`, `google_compute_instance`

### Step 2: Construct the documentation URL

All Terraform provider docs follow a standard URL pattern on the Terraform Registry:

**For resources:**
```
https://registry.terraform.io/providers/{namespace}/{provider}/latest/docs/resources/{resource_name}
```

**For data sources:**
```
https://registry.terraform.io/providers/{namespace}/{provider}/latest/docs/data-sources/{data_source_name}
```

The `{resource_name}` is the resource type with the provider prefix stripped. For example, `alicloud_forward_entry` → `forward_entry`, `aws_instance` → `instance`.

Two quick examples:
- `alicloud_nat_gateway` → `https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/nat_gateway`
- `aws_security_group` → `https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group`

For the full namespace/provider mapping for all 10 cloud providers in the redc-template project (alicloud, aws, tencent, azure, gcp, volcengine, vultr, huaweicloud, ucloud, ctyun), read `references/provider-urls.md`.

To generate URLs programmatically, use the bundled helper: `python scripts/tf_doc_url.py alicloud_forward_entry`

### Step 3: Fetch the page

Use `web_fetch` (or `curl`) to retrieve the documentation page. Read the **Argument Reference** section carefully — it lists every argument, its type, whether it's required/optional, and valid values.

## What to Look For in the Docs

When you fetch a documentation page, focus on these sections:

### 1. Argument Reference
- **Required vs Optional** — which arguments are mandatory
- **Type** — string, number, list, set, map, block
- **Valid values** — enums, format patterns, ranges
- **Conflicts** — arguments that cannot coexist (`conflicts_with`)
- **Force new** — arguments that trigger resource recreation

### 2. Attributes Reference
- What attributes are exported (usable in `output` blocks or other resources)
- Computed attributes (server-assigned, like `id`, `public_ip`)

### 3. Import
- Whether the resource supports `terraform import`
- Import ID format

### 4. Example Usage
- Copy the official example as a starting point
- Pay attention to argument combinations — some are only valid together

## When to Look Up Docs

The cost of looking up docs is ~5 seconds. The cost of guessing wrong is a failed `terraform apply` cycle (30+ seconds per attempt, often 3-5 attempts). The math strongly favors looking things up. Here's when the lookup pays off the most:

1. 🆕 **Writing a new resource** — even if you've seen similar resources before, argument names and valid values differ
2. 🐛 **Debugging a Terraform error** — especially `InvalidParameter`, `InvalidValue`, `Malformed` errors that hint at wrong argument format
3. 🔄 **Changing arguments** — the valid values for one argument may depend on another (e.g., protocol + port constraints)
4. 🤔 **Unsure about format** — port ranges (`1/65535` vs `1-65535`), CIDR blocks, protocol names
5. 📊 **Using data sources** — filter syntax varies wildly between providers
6. 🔗 **Referencing attributes** — the exported attribute name may differ from what you expect

You can safely skip the lookup when making trivial changes (renaming, changing a string default) or when the resource is already working and you're adjusting a value you're certain about.

## Common Pitfalls (Lessons Learned)

These are real issues encountered in the redc-template project. Each was solved instantly by reading the docs:

| Provider | Resource | Pitfall | Correct Value (from docs) |
|----------|----------|---------|--------------------------|
| alicloud | `alicloud_forward_entry` | Port range separator | Use `/` not `-`: `"1/65535"` |
| alicloud | `alicloud_forward_entry` | `ip_protocol` values | Only: `any`, `tcp`, `udp`, `forwardgroup` (lowercase) |
| alicloud | `alicloud_forward_entry` | `any` protocol + port | `ip_protocol=any` requires `port=any`, cannot use port range |
| alicloud | `alicloud_forward_entry` | DNAT + SNAT conflict | Same EIP with port > 1024 needs `port_break = true` |
| alicloud | `alicloud_nat_gateway` | Zone availability | Use `alicloud_enhanced_nat_available_zones` data source |
| aws | `aws_instance` | AMI region-specificity | AMIs are region-bound; use `data.aws_ami` for portability |
| aws | `aws_security_group_rule` | `protocol` values | Use `"-1"` for all protocols, not `"all"` |

## Workflow Example

Here's the ideal workflow when writing a NAT gateway + DNAT rule for Alibaba Cloud:

```
1. Need: alicloud_nat_gateway + alicloud_forward_entry

2. Fetch docs:
   → web_fetch("https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/nat_gateway")
   → web_fetch("https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/forward_entry")

3. Read Argument Reference:
   - nat_gateway: nat_type (Enhanced required for EIP), vswitch_id required
   - forward_entry: ip_protocol accepts (any|tcp|udp|forwardgroup)
   - forward_entry: external_port/internal_port format is "port/port" for range
   - forward_entry: port_break required when SNAT shares same EIP

4. Write Terraform code based on docs → works first time ✅
```

Compare with guessing:
```
1. Guess port format: "1-65535" → ❌ InvalidExternalPort.Malformed
2. Try "1:65535" → ❌ InvalidExternalPort.Malformed
3. Try port="any" with tcp → ❌ OperationFailed.AnyPortConfig
4. Google the error → find docs → "1/65535" works → ✅ (after 4 attempts)
```

## Bundled Resources

- **`references/provider-urls.md`** — Complete URL patterns and examples for all 10 cloud providers. Read this when you need the exact namespace/provider mapping for a provider you haven't used before.
- **`scripts/tf_doc_url.py`** — CLI tool to generate doc URLs from resource type names. Run `python scripts/tf_doc_url.py <resource_type>` to quickly get the URL.
