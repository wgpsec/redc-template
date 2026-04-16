# Terraform Provider URL Reference

Complete URL patterns for all cloud providers used in the redc-template project. The general pattern is:

```
https://registry.terraform.io/providers/{namespace}/{provider}/latest/docs/resources/{resource_name_without_prefix}
```

Strip the provider prefix (e.g., `alicloud_`, `aws_`, `azurerm_`) from the resource type to get the URL path segment.

---

## Alibaba Cloud (alicloud)

| Type | URL Pattern |
|------|------------|
| Provider | `https://registry.terraform.io/providers/aliyun/alicloud/latest/docs` |
| Resource | `https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/{name}` |
| Data Source | `https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/{name}` |

Strip the `alicloud_` prefix for the URL path. Examples:
- `alicloud_instance` → `.../resources/instance`
- `alicloud_forward_entry` → `.../resources/forward_entry`
- `alicloud_nat_gateway` → `.../resources/nat_gateway`
- `alicloud_eip_address` → `.../resources/eip_address`
- Data source `alicloud_zones` → `.../data-sources/zones`
- Data source `alicloud_enhanced_nat_available_zones` → `.../data-sources/enhanced_nat_available_zones`

**Alternative (Chinese docs, sometimes more detailed):**
```
https://www.alibabacloud.com/help/zh/terraform/developer-reference/resource-alicloud-xxx
```

## AWS

| Type | URL Pattern |
|------|------------|
| Provider | `https://registry.terraform.io/providers/hashicorp/aws/latest/docs` |
| Resource | `https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/{name}` |
| Data Source | `https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/{name}` |

Strip the `aws_` prefix. Examples:
- `aws_instance` → `.../resources/instance`
- `aws_security_group` → `.../resources/security_group`
- `aws_key_pair` → `.../resources/key_pair`
- `aws_spot_instance_request` → `.../resources/spot_instance_request`

## Tencent Cloud

| Type | URL Pattern |
|------|------------|
| Provider | `https://registry.terraform.io/providers/tencentcloudstack/tencentcloud/latest/docs` |
| Resource | `https://registry.terraform.io/providers/tencentcloudstack/tencentcloud/latest/docs/resources/{name}` |
| Data Source | `https://registry.terraform.io/providers/tencentcloudstack/tencentcloud/latest/docs/data-sources/{name}` |

Strip the `tencentcloud_` prefix. Examples:
- `tencentcloud_instance` → `.../resources/instance`
- `tencentcloud_vpc` → `.../resources/vpc`
- `tencentcloud_security_group` → `.../resources/security_group`

## Azure

| Type | URL Pattern |
|------|------------|
| Provider | `https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs` |
| Resource | `https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/{name}` |
| Data Source | `https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/{name}` |

Strip the `azurerm_` prefix. Examples:
- `azurerm_linux_virtual_machine` → `.../resources/linux_virtual_machine`
- `azurerm_network_security_group` → `.../resources/network_security_group`

## Google Cloud (GCP)

| Type | URL Pattern |
|------|------------|
| Provider | `https://registry.terraform.io/providers/hashicorp/google/latest/docs` |
| Resource | `https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/{name}` |
| Data Source | `https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/{name}` |

Strip the `google_` prefix. Examples:
- `google_compute_instance` → `.../resources/compute_instance`
- `google_compute_firewall` → `.../resources/compute_firewall`

## Volcengine (火山引擎)

| Type | URL Pattern |
|------|------------|
| Provider | `https://registry.terraform.io/providers/volcengine/volcengine/latest/docs` |
| Resource | `https://registry.terraform.io/providers/volcengine/volcengine/latest/docs/resources/{name}` |
| Data Source | `https://registry.terraform.io/providers/volcengine/volcengine/latest/docs/data-sources/{name}` |

Strip the `volcengine_` prefix. Examples:
- `volcengine_ecs_instance` → `.../resources/ecs_instance`
- `volcengine_eip_address` → `.../resources/eip_address`

## Vultr

| Type | URL Pattern |
|------|------------|
| Provider | `https://registry.terraform.io/providers/vultr/vultr/latest/docs` |
| Resource | `https://registry.terraform.io/providers/vultr/vultr/latest/docs/resources/{name}` |

Strip the `vultr_` prefix. Examples:
- `vultr_instance` → `.../resources/instance`

## Huawei Cloud

| Type | URL Pattern |
|------|------------|
| Provider | `https://registry.terraform.io/providers/huaweicloud/huaweicloud/latest/docs` |
| Resource | `https://registry.terraform.io/providers/huaweicloud/huaweicloud/latest/docs/resources/{name}` |

Strip the `huaweicloud_` prefix. Examples:
- `huaweicloud_compute_instance` → `.../resources/compute_instance`

## UCloud

| Type | URL Pattern |
|------|------------|
| Provider | `https://registry.terraform.io/providers/ucloud/ucloud/latest/docs` |
| Resource | `https://registry.terraform.io/providers/ucloud/ucloud/latest/docs/resources/{name}` |

## CTyun (天翼云)

| Type | URL Pattern |
|------|------------|
| Provider | `https://registry.terraform.io/providers/ctyun-it/ctyun/latest/docs` |
| Resource | `https://registry.terraform.io/providers/ctyun-it/ctyun/latest/docs/resources/{name}` |
