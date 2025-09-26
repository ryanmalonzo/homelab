# Homelab Infrastructure Copilot Instructions

## Architecture Overview

This is a **three-layer homelab infrastructure** built around Proxmox virtualization:

1. **Proxmox Host** (192.168.1.35) - Physical server running ZFS storage and NFS shares
2. **Docker VM** (192.168.1.253) - Debian 13 VM running containerized services
3. **Services Layer** - Media stack (Jellyfin, Sonarr, Radarr) and management tools (Komodo)

**Data Flow**: Proxmox ZFS pool → NFS exports → Docker VM mounts → Container volumes

## Key Infrastructure Patterns

### Terraform + Cloud-Init VM Provisioning

- VMs are created via `terraform/proxmox/` with cloud-init templates in `cloud-init/`
- Debian 13 Trixie images with Intel graphics drivers, Docker, and NFS client pre-installed
- SSH key from `ssh/key.pub` is automatically deployed
- **Always template cloud-init changes** - don't hardcode values in YAML files

### Ansible Configuration Management

- **Two-phase deployment**: `ansible-playbook playbooks/site.yml` runs both `proxmox.yml` then `docker.yml`
- **Inventory pattern**: `ansible/inventory/hosts.yml` defines `proxmox` and `docker` host groups
- **Role dependency order matters**: Proxmox roles (zfs → nfs → media_dirs) must run before Docker roles (nfs_client → docker_services)

### Docker Services Architecture

- **Socket proxy pattern**: All services connect through socket-proxy network for security
- **Docker Compose templating**: Services deployed via Ansible templates (`.j2` files) not direct compose files
- **Volume strategy**: `{{ docker_appdata }}:/opt/appdata` for persistent data, NFS mounts for media

## Critical Workflows

### Deploy Infrastructure Changes

```bash
# 1. Install Ansible dependencies (always run first)
ansible-galaxy install -r ansible/requirements.yml -p ansible/galaxy_roles

# 2. Deploy all infrastructure
ansible-playbook ansible/playbooks/site.yml

# 3. Deploy specific layer
ansible-playbook ansible/playbooks/proxmox.yml  # Storage/NFS only
ansible-playbook ansible/playbooks/docker.yml   # Services only
```

### Terraform VM Management

```bash
cd terraform/proxmox
terraform plan    # Always review before apply
terraform apply   # Creates VM with cloud-init
```

## Configuration Conventions

### Variable Hierarchy

- `group_vars/all.yml` - Global settings (NFS shares, network, timezone)
- `group_vars/proxmox.yml` - Host-specific overrides (ZFS devices)
- Role `defaults/main.yml` - Service-specific defaults

### NFS Sharing Pattern

```yaml
# Define in all.yml
zfs_datasets: [media, music, photos, files]
nfs_shares:
  - name: media
    mount_point: /mnt/media
```

Creates: ZFS dataset → NFS export → Docker VM mount point

### Docker Compose Extensions

Uses YAML anchors for DRY patterns:

- `&common-variables` - PUID/PGID/TZ environment
- `&restart-policy` - Standard restart policies
- `&linuxserver-base` - Common LinuxServer.io container config

## Integration Points

- **SSH Keys**: Centralized in `ssh/key.pub`, deployed by Terraform cloud-init and Ansible
- **Network**: Fixed IPs in inventory must match Terraform outputs and NFS client configs
- **Storage**: ZFS pool name in `group_vars/proxmox.yml` must match dataset references
- **Docker Networks**: `socket-proxy` network bridges all services securely
- **Cloudflare**: DNS managed separately in `terraform/cloudflare/`

## Service-Specific Notes

### Jellyfin Stack

- Hardware transcoding enabled (Intel graphics drivers in cloud-init)
- Media paths mounted from NFS: `/mnt/{media,music,photos}`
- Uses LinuxServer.io images with common environment pattern

### Komodo (Docker Management)

- MongoDB backend with resource limits (`--wiredTigerCacheSizeGB 0.25`)
- Environment file templated by Ansible (`komodo.env.j2`)
- Prevents self-management with `komodo.skip` label

When modifying services, **always update Ansible templates**, not the deployed compose files directly.
