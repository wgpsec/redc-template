# GCP Compute Instance

## Scene Description

This scene deploys a basic Compute Engine instance in GCP `us-central1-a`. The default size is `e2-micro`, making it a lightweight option for quickly bringing up a minimal test host while still allowing overrides for the project ID, machine type, zone, and image.

## Prerequisites

- redc must already be configured with a GCP service account JSON credential file.
- The target project must have the Compute Engine API enabled, and the service account needs permission to create instances.
- You must explicitly override `GCP_PROJECT_ID` when running the scene. The default value in the template is only a repository example, and the provider uses this variable directly as the target project.

## Quick Start

Pull the scene:

```bash
redc pull gcp/compute_instance
```

Run with an explicit project ID:

```bash
redc run gcp/compute_instance -e GCP_PROJECT_ID=your-project-id
```

Override the machine type, zone, or image when needed:

```bash
redc run gcp/compute_instance \
  -e GCP_PROJECT_ID=your-project-id \
  -e instance_machine_type=e2-small \
  -e zone=us-central1-b \
  -e image=ubuntu-minimal-2210-kinetic-amd64-v20230126
```

Check the runtime status:

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
| `GCP_PROJECT_ID` | `redc-488606` | GCP project ID. This default is only a repository example, so you must override it in real usage. |
| `instance_name` | `vm-test` | Instance name. |
| `instance_machine_type` | `e2-micro` | Machine type. |
| `location` | `us-central1` | Reserved variable. The current template does not use it for resource creation; `zone` is what actually controls placement. |
| `zone` | `us-central1-a` | Availability zone. |
| `image` | `ubuntu-minimal-2210-kinetic-amd64-v20230126` | Boot image name. |

## Outputs

- `instance_ip` / `public_ip`: Instance public IP address.
- `ssh_user`: Compatibility output currently hard-coded as `ubuntu`; do not assume it is your real GCP login username.
- `ssh_command`: Basic connection string emitted by the template, mainly useful for identifying the target IP; it is not guaranteed to complete login directly.
- `ssh_private_key_path`: Always empty. Unlike AWS or Tencent scenes, this scene does not generate a local private key file.

## Notes

- SSH access in GCP depends on your current authentication mode. The current template does not generate a local private key and does not determine the final OS Login username. If the emitted `ssh_command` is not sufficient, use `gcloud compute ssh` or follow your OS Login / project SSH key policy.
- The current resource creation path actually uses `zone`. If you need to change placement, override `zone` first.
- Common failure causes are GCP API network timeouts, the Compute Engine API not being enabled, insufficient service account permissions, or capacity shortages in the selected zone.
