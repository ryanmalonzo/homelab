# Copilot Instructions for Homelab Infrastructure

## Project Architecture

This is a homelab infrastructure project managing Proxmox VMs with Terraform and configuring services with Ansible. The architecture follows a two-tier approach:

- **Proxmox Host** (`192.168.1.35`): ZFS storage backend with NFS exports for shared media/data
- **Docker VM** (`192.168.1.253`): Debian VM running containerized services, consumes NFS mounts

## Key Workflows

### Initial Setup

```bash
# Install Ansible dependencies first
cd ansible && ansible-galaxy install -r requirements.yml -p galaxy_roles

# Deploy infrastructure (run from terraform/proxmox/)
terraform plan && terraform apply

# Configure all services
cd ../../ansible && ansible-playbook playbooks/site.yml
```

### Service Management

- Individual playbooks: `ansible-playbook playbooks/docker.yml` or `playbooks/proxmox.yml`
- Docker services use socket-proxy pattern for security (see `roles/docker_services`)
- All services configured via Ansible templates, never manual Docker commands

## Coding Practices

- **Minimal changes only**: Make the smallest possible change to achieve the requested outcome
- **No over-engineering**: Resist the urge to refactor or improve code beyond what was asked
- **Scope limitation**: Only change what was specifically requested, nothing more
- **Comments**: Only add comments where genuinely needed for clarity, use human-like language, no emojis
- **Mandatory testing**: After completing each step, test the changes to ensure they work as expected before proceeding

## AI Workflow

When prompted to do something, always architect a plan first, asking any and all questions you may have for clarification, then wait for validation.

After implementing each logical step:

1. **Test the changes** - Verify the implementation works correctly using appropriate testing methods
2. **Commit immediately** - Create a semantic commit for each completed step using the convention: `type(scope): description`

### Semantic Commit Convention

- Use conventional commit format: `type(scope): description`
- **Types**: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`
- **Scopes**: Match existing project scopes from git history or create minimal new ones when necessary
- **Description**: Clear, concise summary of what was changed
- **One commit per logical step**: Don't bundle multiple unrelated changes

Example existing scopes: `ansible`, `docker`, `terraform`, `zfs`, `gitignore`, `instructions`
Example commits: `feat(docker): add nginx service configuration`, `fix(ansible): correct NFS mount permissions`

## Critical Conventions

### Ansible Structure

- **Galaxy roles** in `galaxy_roles/` (external dependencies from `requirements.yml`)
- **Custom roles** in `roles/` for project-specific logic
- **Group variables** define infrastructure topology (`group_vars/all.yml`, `docker.yml`, `proxmox.yml`)
- **SSH key management**: Uses `chaldea` key at `/Users/ryanmalonzo/.ssh/chaldea` for all hosts

### Storage & Networking

- **ZFS pool**: Always named `tank` with datasets: `media`, `music`, `photos`, `files`
- **NFS mounts**: Docker VM mounts all datasets from Proxmox host at `/mnt/{dataset}`
- **Docker networks**: Use `socket-proxy` network for secure Docker socket access
- **User mapping**: NFS exports use `anonuid=1000,anongid=1000` for consistent permissions

### Terraform Patterns

- **Cloud-init templating**: Variables injected into `cloud-init/user-data.yaml` template
- **Provider configuration**: Not committed (create `provider.tf` with Proxmox credentials)
- **VM specs**: Defaults in `variables.tf` - 4 cores, 16GB RAM, 100GB disk
- **Debian image**: Uses genericcloud image with non-free repos for Intel graphics

## Integration Points

### Docker Service Deployment

Services follow this pattern (see `roles/docker_services/tasks/main.yml`):

1. Create Docker network and volumes
2. Template compose files with secrets from environment
3. Deploy via `community.docker.docker_compose_v2`
4. Use socket-proxy for secure Docker API access

### Environment Variables

- **Newt service**: Requires `NEWT_ID` and `NEWT_SECRET` environment variables
- **Pangolin endpoint**: Hardcoded to `https://pangolin.ryanmalonzo.com`

### File Locations

- **Docker configs**: `/home/chaldea/{service-name}/compose.yaml`
- **Ansible templates**: `roles/{role}/templates/` for dynamic configs
- **Static files**: `roles/{role}/files/` for copying unchanged configs

## Common Tasks

- **Adding new Docker service**: Create template in `roles/docker_services/templates/`, add deployment task
- **Modifying ZFS datasets**: Update `group_vars/all.yml` and both `proxmox.yml` + `docker.yml` playbooks
- **VM configuration changes**: Modify `terraform/proxmox/variables.tf` and cloud-init templates
- **Network changes**: Update inventory hosts and group_vars for new IP addresses

## Security Notes

- SSH uses key-based auth only (`IdentitiesOnly=yes` in inventory)
- NFS exports restricted to `192.168.1.0/24` subnet
- Terraform state contains sensitive data - handle carefully
