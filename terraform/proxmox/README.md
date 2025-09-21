# Proxmox Debian 13 Trixie VM with Terraform

This Terraform configuration creates a Debian 13 Trixie virtual machine on Proxmox with Docker, NFS client, and Intel graphics support using cloud-init for automated configuration.

## Features

- **Debian 13 Trixie**: Latest Debian testing release with genericcloud image
- **Docker**: Automatically installed and configured for the user
- **Intel Graphics**: Hardware acceleration drivers and tools (vainfo, intel-media-va-driver-non-free)
- **NFS Client**: Ready for network storage connectivity
- **QEMU Guest Agent**: Enabled for Proxmox integration
- **Cloud-init**: Fully automated system configuration
- **SSH Access**: Key-based authentication (no password)

## Prerequisites

1. **Proxmox VE**: Running Proxmox Virtual Environment
2. **Terraform**: Version ~> 1.12 installed
3. **bpg/proxmox provider**: Version 0.83.2 (configured in versions.tf)
4. **SSH Key**: Public key file available at `../../ssh/key.pub`
5. **Proxmox API Access**: Provider configuration (not included in this repo for security)

## Quick Start

1. **Configure Proxmox Provider**: Create a `provider.tf` file with your Proxmox connection details:
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
     # or use API tokens for better security
     insecure = true  # Only for testing
   }
   ```

2. **Copy and customize variables**:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your specific values
   ```

3. **Initialize and deploy**:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

4. **Connect to your VM**:
   ```bash
   # Use the SSH command from Terraform output
   ssh chaldea@<vm-ip-address>
   ```

## Configuration

### Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `proxmox_node` | Proxmox node name | `"pve"` |
| `vm_name` | VM name | `"docker"` |
| `vm_cpu_cores` | Number of CPU cores | `4` |
| `vm_memory` | RAM in MB | `8192` |
| `vm_disk_size` | Disk size in GB | `100` |
| `vm_disk_datastore` | VM disk datastore | `"local-lvm"` |
| `snippets_datastore` | Cloud-init snippets datastore | `"local"` |
| `network_bridge` | Network bridge | `"vmbr0"` |
| `username` | VM user account | `"chaldea"` |
| `hostname` | VM hostname | `"docker"` |
| `timezone` | System timezone | `"Europe/Paris"` |

### Cloud-init Configuration

The VM is configured with:

- **User Account**: `chaldea` with sudo privileges and Docker access
- **SSH Access**: Key-based authentication using your public key
- **Packages**: Docker, NFS client, Intel graphics drivers, development tools
- **Services**: QEMU guest agent, Docker daemon
- **Repositories**: Debian non-free repos enabled for Intel drivers

## Post-Deployment

### Verify Installation

```bash
# Check system status
ssh chaldea@<vm-ip> 'systemctl status qemu-guest-agent docker'

# Test Docker access
ssh chaldea@<vm-ip> 'docker --version && docker ps'

# Check Intel graphics
ssh chaldea@<vm-ip> 'vainfo'

# Test NFS tools
ssh chaldea@<vm-ip> 'showmount --help'
```

### Docker Usage

The `chaldea` user can run Docker commands without sudo:

```bash
ssh chaldea@<vm-ip>
docker run hello-world
docker-compose --version  # Available for container orchestration
```

### NFS Mounting

NFS client tools are ready for network storage:

```bash
# Example NFS mount
sudo mount -t nfs4 nfs-server:/path/to/share /mnt/nfs
```

## File Structure

```
terraform/proxmox/
├── versions.tf              # Terraform and provider versions
├── variables.tf             # Variable definitions
├── terraform.tfvars.example # Example configuration
├── terraform.tfvars         # Your configuration (gitignored)
├── main.tf                  # Main VM resources
├── outputs.tf               # Output values
├── cloud-init/
│   ├── user-data.yaml      # Cloud-init user configuration
│   └── meta-data.yaml      # Cloud-init metadata
└── README.md               # This file
```

## Customization

### Adding Packages

Edit `cloud-init/user-data.yaml` and add packages to the `packages` list:

```yaml
packages:
  - your-package-name
```

### Custom Commands

Add commands to the `runcmd` section in `user-data.yaml`:

```yaml
runcmd:
  - your-custom-command
```

### Container Auto-start

You can add Docker containers to start automatically:

```yaml
runcmd:
  - docker run -d --name your-container your-image
```

## Troubleshooting

### Cloud-init Issues
```bash
# Check cloud-init status
ssh chaldea@<vm-ip> 'sudo cloud-init status'

# View cloud-init logs
ssh chaldea@<vm-ip> 'sudo journalctl -u cloud-init'
```

### QEMU Guest Agent
```bash
# Check agent status
ssh chaldea@<vm-ip> 'sudo systemctl status qemu-guest-agent'
```

### Docker Issues
```bash
# Check Docker daemon
ssh chaldea@<vm-ip> 'sudo systemctl status docker'

# Check user groups
ssh chaldea@<vm-ip> 'groups'
```

## Security Notes

- The VM uses SSH key authentication only (no password)
- The user has passwordless sudo access for convenience
- Terraform state may contain sensitive information - secure your state files
- Consider using Proxmox API tokens instead of username/password

## Clean Up

To destroy the VM and resources:

```bash
terraform destroy
```

This will remove the VM, cloud-init files, and downloaded image from Proxmox.