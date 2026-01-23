# redc-template

[中文](README_CN.md) | English

Terraform template repository used by the https://github.com/wgpsec/redc engine

Template writing guide (English): [WRITING_TEMPLATES_EN.md](WRITING_TEMPLATES_EN.md)

## Category Explanation

Classified by cloud providers

- aliyun: Various scenarios on Alibaba Cloud
- aws: Various scenarios on Amazon Web Services
- tencent: Various scenarios on Tencent Cloud
- vultr: Scenarios on Vultr Cloud (not recommended, better to use AWS)

More cloud providers like Huawei Cloud, Volcano Engine, etc. will be added gradually

## Prerequisites

Alibaba Cloud
- aksk (requires permissions to create instances, VPC, vswitch, and security groups. Use high permissions if you want to avoid complexity)

Tencent Cloud
- aksk (same as above)

AWS
- aksk (same as above)
- launch_template id (Launch template ID. Create a launch template in the AWS console, copy the ID, and replace the ID in the Terraform template)
- SSH key generated in your AWS console, save it locally

Vultr (not recommended)
- aksk (same as above)

## How to Use

Recommended to use with the redc tool
- https://github.com/wgpsec/redc

> Note: Each template scenario folder can be used independently, meaning "independent use without relying on the redc engine"

## File Storage Planning

Static resources required at runtime are downloaded through proxy links defined in github_proxy in the template. AWS scenarios do not need to consider proxies.

Files generated after execution are stored on R2 storage, implemented through the upload_r2 module of the redc engine

## Security

This repository uses GitHub Actions to automatically check for sensitive information:

- **Secret Scanning**: Automatically detects access keys (AK), secret keys (SK), passwords, and other sensitive information in the code
- **CI/CD Integration**: Scanning is triggered on every push and pull request
- **Leak Prevention**: CI fails and blocks merging when sensitive information is detected

⚠️ **Important**: Do not write real AK/SK, passwords, or other sensitive information directly into the code. Use environment variables or configuration files to manage sensitive information.
