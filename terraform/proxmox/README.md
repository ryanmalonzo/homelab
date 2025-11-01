# Proxmox Debian 13 VM Deployment

Terraform configuration for deploying a Debian 13 "Trixie" virtual machine on Proxmox. The VM is pre-configured with Docker, NFS client, and Intel graphics support via cloud-init.

## Features

- **Debian 13 Trixie**: Utilizes the latest Debian testing release with a `generic-amd64` cloud image.
- **Docker**: Automatic installation and configuration.
- **Intel Graphics**: Includes drivers and tools for hardware acceleration.
- **NFS Client**: Configured for network storage.
- **QEMU Guest Agent**: Enabled for Proxmox integration.
- **Cloud-init**: Automated system configuration.
- **SSH Access**: Key-based authentication.

## Setup

### Prerequisites

1. **Proxmox VE**: Running Proxmox Virtual Environment.
2. **Terraform**: Version `~> 1.12`.
3. **Proxmox Provider**: `bpg/proxmox` provider, version `0.83.2` (defined in `versions.tf`).
4. **SSH Key**: Public key file at `../../ssh/key.pub`.
5. **Proxmox API Access**: Provider configuration required (not included for security).

### Deployment Steps

1. **Proxmox Provider Configuration**: Create `provider.tf` with Proxmox connection details. API tokens can be used for provider authentication.

    ```hcl
    terraform {
      required_providers {
        proxmox = {
          source = "bpg/proxmox"
          version = "0.83.2"
        }
      }
    }

    provider "proxmox" {
      endpoint = "https://your-proxmox-host:8006/"
      username = "your-username@pam"
      password = "your-password"
      insecure = true  # For testing only
    }
    ```

2. **Variable Customization**: Copy `terraform.tfvars.example` to `terraform.tfvars` and modify the values as needed.

    ```bash
    cp terraform.tfvars.example terraform.tfvars
    # Edit terraform.tfvars
    ```

3. **Initialization and Deployment**:

    ```bash
    terraform init
    terraform plan
    terraform apply
    ```

4. **SSH Connection**: Connect to the VM using the SSH command from Terraform output.

    ```bash
    ssh chaldea@<vm-ip-address>
    ```

## Configuration

### Terraform Variables

Adjustable variables:

| Variable             | Description                 | Default          |
| :------------------- | :-------------------------- | :--------------- |
| `proxmox_node`       | Proxmox node name           | `"pve"`          |
| `vm_name`            | Virtual machine name        | `"docker"`       |
| `vm_cpu_cores`       | Number of CPU cores         | `4`              |
| `vm_memory`          | RAM in MB                   | `16384`          |
| `vm_disk_size`       | Disk size in GB             | `100`            |
| `vm_disk_datastore`  | VM disk storage             | `"local-lvm"`    |
| `snippets_datastore` | Cloud-init snippets storage | `"local"`        |
| `network_bridge`     | Network bridge              | `"vmbr0"`        |
| `username`           | VM user account             | `"chaldea"`      |
| `hostname`           | VM hostname                 | `"docker"`       |
| `timezone`           | System timezone             | `"Europe/Paris"` |

### Cloud-init Configuration

Initial VM configuration via cloud-init:

- **User**: `chaldea` user with `sudo` and Docker access.
- **SSH**: Key-based authentication using the provided public key.
- **Packages**: Docker, NFS client, Intel graphics drivers, development tools.
- **Services**: QEMU guest agent, Docker daemon.
- **Repositories**: Debian non-free repositories enabled for Intel drivers.

## Post-Deployment Verification

Verify setup after deployment:

- **System Status**:

  ```bash
  ssh chaldea@<vm-ip> 'systemctl status qemu-guest-agent docker'
  ```

- **Docker**:

  ```bash
  ssh chaldea@<vm-ip> 'docker --version && docker ps'
  ```

- **Intel Graphics**:

  ```bash
  ssh chaldea@<vm-ip> 'vainfo'
  ```

- **NFS Tools**:

  ```bash
  ssh chaldea@<vm-ip> 'showmount --help'
  ```

## iGPU Passthrough Setup (Proxmox Host)

### 1. Edit GRUB Configuration

Edit `/etc/default/grub` and add `quiet intel_iommu=on iommu=pt` to the `GRUB_CMDLINE_LINUX_DEFAULT` line.

### 2. Create VFIO Modules Configuration

Create `/etc/modules-load.d/vfio.conf` with the following content:

```
vfio
vfio_iommu_type1
vfio_pci
vfio_virqfd
```

### 3. Apply Changes and Reboot

```bash
update-grub
update-initramfs -u -k all
reboot
```

### 4. Verify Passthrough

After rebooting, verify the iGPU is using the `vfio-pci` driver:

```bash
lspci -nnk | grep -A3 VGA
```

The output should show `Kernel driver in use: vfio-pci`.

## Customization

- **Package Addition**: Add packages to the `packages` list in `cloud-init/user-data.yaml`.
- **Custom Commands**: Add commands to the `runcmd` section in `cloud-init/user-data.yaml`.
- **Docker Container Auto-start**: Configure Docker containers for automatic startup within the `runcmd` section.

## Troubleshooting

- **Cloud-init Issues**:

  ```bash
  ssh chaldea@<vm-ip> 'sudo cloud-init status'
  ssh chaldea@<vm-ip> 'sudo journalctl -u cloud-init'
  ```

- **QEMU Guest Agent**:

  ```bash
  ssh chaldea@<vm-ip> 'sudo systemctl status qemu-guest-agent'
  ```

- **Docker Issues**:

  ```bash
  ssh chaldea@<vm-ip> 'sudo systemctl status docker'
  ssh chaldea@<vm-ip> 'groups'
  ```

## Security Considerations

- SSH key authentication is used exclusively.
- The default user has passwordless `sudo` access.
- Terraform state files may contain sensitive information and should be stored securely.
- Proxmox API tokens can be used for provider authentication in place of a username and password.

## Cleanup

To destroy the VM and associated resources:

```bash
terraform destroy
```

This command removes the VM, cloud-init files, and downloaded images from Proxmox.

