#!/usr/bin/env python3
"""Generate Terraform Registry documentation URL from a resource type name.

Usage:
    python tf_doc_url.py alicloud_forward_entry
    python tf_doc_url.py aws_instance
    python tf_doc_url.py --data-source alicloud_zones
"""

import sys

PROVIDERS = {
    'alicloud':      ('aliyun', 'alicloud'),
    'aws':           ('hashicorp', 'aws'),
    'azurerm':       ('hashicorp', 'azurerm'),
    'google':        ('hashicorp', 'google'),
    'tencentcloud':  ('tencentcloudstack', 'tencentcloud'),
    'volcengine':    ('volcengine', 'volcengine'),
    'vultr':         ('vultr', 'vultr'),
    'huaweicloud':   ('huaweicloud', 'huaweicloud'),
    'ucloud':        ('ucloud', 'ucloud'),
    'ctyun':         ('ctyun-it', 'ctyun'),
}


def tf_doc_url(resource_type, is_data_source=False):
    """Generate Terraform Registry doc URL from resource type."""
    prefix = resource_type.split('_')[0]
    if prefix not in PROVIDERS:
        return None
    ns, prov = PROVIDERS[prefix]
    name = resource_type[len(prefix) + 1:]
    kind = 'data-sources' if is_data_source else 'resources'
    return f"https://registry.terraform.io/providers/{ns}/{prov}/latest/docs/{kind}/{name}"


if __name__ == '__main__':
    is_ds = '--data-source' in sys.argv
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    if not args:
        print("Usage: python tf_doc_url.py [--data-source] <resource_type>")
        print("Example: python tf_doc_url.py alicloud_forward_entry")
        sys.exit(1)
    for rt in args:
        url = tf_doc_url(rt, is_data_source=is_ds)
        if url:
            print(url)
        else:
            print(f"Unknown provider prefix in: {rt}", file=sys.stderr)
            sys.exit(1)
