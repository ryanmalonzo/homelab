# Ansible

## Install Dependencies

```bash
ansible-galaxy install -r requirements.yml -p galaxy_roles
```

## Run Playbooks

### All playbooks

```bash
ansible-playbook playbooks/site.yml
```

### Individual playbooks

```bash
# Proxmox setup
ansible-playbook playbooks/proxmox.yml

# Docker services
ansible-playbook playbooks/docker.yml
```
