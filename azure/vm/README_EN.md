# Azure VM

## Scene Description

This scene creates a password-based Linux virtual machine in Azure `West Europe` and returns the public IP plus SSH login information. In practice, the current template is better treated as a reference preset, because the repository metadata already notes that it was not validated consistently due to Azure quota issues.

## Prerequisites

- redc must already be configured with working Azure service principal credentials.
- The target subscription must have available quota and SKU capacity for `Standard_D2a_v4` in `West Europe`.
- The current template uses fixed names for the resource group, network objects, NIC, and VM. Repeated runs in the same subscription can collide with existing resources.

## Quick Start

```bash
redc pull azure/vm
redc run azure/vm
redc status [uuid]
redc stop [uuid]
```

To override the administrator password explicitly:

```bash
redc run azure/vm -e instance_password='YourPassword123!'
```

## Parameters

| Parameter | Default | Description |
| --- | --- | --- |
| `instance_password` | auto-generated | VM administrator password. If left empty, the template generates a random one. |

## Outputs

- `public_ip`: VM public IP address.
- `ecs_password` / `ssh_password`: Effective login password.
- `ssh_user`: Default SSH username, currently `redcadmin`.
- `ssh_command`: Copy-ready SSH command.

## Notes

- The region is fixed to `West Europe`.
- The VM size is fixed to `Standard_D2a_v4`, and the image is fixed to `Ubuntu 18.04-LTS`.
- The current template uses password-based login and does not provision SSH keys.
- Because the scene metadata already states that the template was not successfully validated due to quota limitations, `SkuNotAvailable` and `quota exceeded` should be treated as known operational risks rather than documentation gaps.
- Common failure causes are invalid Azure credentials, insufficient regional quota, unavailable SKU capacity, or collisions with the fixed resource names.

## Appendix

- Current fixed resource names include resource group `redc-resources-1`, virtual machine `test-machine`, NIC `test-nic`, and public IP `test-publicip`.
- The template does not expose `location` or `vm_size` as user-facing variables. If you need to change the region or VM size, edit [main.tf](main.tf).
