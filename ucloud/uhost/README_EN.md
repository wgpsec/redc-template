# UCloud UHost

## Scene Description

This scene creates a general-purpose UHost instance on UCloud. By default it uses region `cn-bj2`, availability zone `cn-bj2-05`, instance type `o-basic-1`, and automatically binds a public EIP. The image lookup targets Debian 12.7, the system disk uses `cloud_ssd`, and the instance also gets an extra 20GB data disk, making it suitable as a generic base node or temporary operations host.

## Prerequisites

- You need valid UCloud credentials and a project ID: `ucloud_public_key`, `ucloud_private_key`, and `ucloud_project_id`.
- Those values can come from your local redc provider configuration or be passed explicitly with `-e` when running the scene.
- It is strongly recommended to set `instance_password` explicitly. The variable default is empty, and if you do not provide it, the `ssh_password` output will also be empty.
- Any custom `instance_password` must be 8-30 characters long and include uppercase letters, lowercase letters, digits, and special characters.

## Quick Start

Pull the scene:

```bash
redc pull ucloud/uhost
```

Start the scene with the required credentials and a login password:

```bash
redc run ucloud/uhost \
  -e ucloud_public_key=YOUR_PUBLIC_KEY \
  -e ucloud_private_key=YOUR_PRIVATE_KEY \
  -e ucloud_project_id=YOUR_PROJECT_ID \
  -e instance_password='YourPassword123!'
```

Override the zone, instance name, or instance type if needed:

```bash
redc run ucloud/uhost \
  -e ucloud_public_key=YOUR_PUBLIC_KEY \
  -e ucloud_private_key=YOUR_PRIVATE_KEY \
  -e ucloud_project_id=YOUR_PROJECT_ID \
  -e instance_password='YourPassword123!' \
  -e availability_zone=cn-bj2-05 \
  -e instance_name=redc-uhost \
  -e instance_type=o-basic-1
```

Check the running status:

```bash
redc status [uuid]
```

Stop the scene:

```bash
redc stop [uuid]
```

## Parameters

| Parameter | Default | Description |
| --- | --- | --- |
| `region` | `cn-bj2` | UCloud region. |
| `ucloud_public_key` | empty | UCloud API Public Key. |
| `ucloud_private_key` | empty | UCloud API Private Key. |
| `ucloud_project_id` | empty | UCloud project ID. |
| `availability_zone` | `cn-bj2-05` | Instance availability zone. |
| `instance_name` | `redc-uhost` | UHost instance name. |
| `instance_type` | `o-basic-1` | UHost instance type. |
| `instance_password` | empty | Root login password. Passing it explicitly is recommended. |

## Outputs

- `instance_id`: UHost instance ID.
- `instance_name`: UHost instance name.
- `private_ip`: Private IP address of the instance.
- `public_ip`: Public IP address after the EIP is associated.
- `ssh_user`: Default SSH username, currently `root`.
- `ssh_password`: Instance password, taken directly from `instance_password`.
- `ssh_command`: Copy-ready SSH command.

## Notes

- The provider region is controlled by `region`, but the Debian 12.7 image lookup depends on `availability_zone`. If you change the region or zone, confirm that a matching image still exists there.
- The template creates a dedicated VPC, subnet, and EIP, and also attaches a 20GB `cloud_ssd` data disk to the instance.
- The template reuses UCloud's recommended `recommend_web` security group rather than defining narrower rules locally. Tighten exposure after deployment if you plan to keep the host online.
- There is no additional user data bootstrap logic, so this scene gives you a relatively clean Debian base host.
