# chaldea

My self-deploying homelab infrastructure using NixOS and Terraform. Automated backups, continuous deployment, monitoring, version control.

## Structure

```
.
├── .github/workflows/
│   ├── ci.yaml
│   ├── cd.yaml
│   └── ...
├── modules/
│   ├── backups.nix         # restic to backblaze b2
│   ├── caddy.nix
│   ├── dns.nix
│   ├── networking.nix
│   ├── virtualisation.nix
│   ├── zfs.nix
│   └── ...
├── services/               # individual service definitions
├── terraform/              # cloudflare dns records
├── secrets/                # sops-encrypted secrets
├── configuration.nix
├── flake.nix
└── hardware-configuration.nix
```

## Tech stack

- **NixOS** with flakes — declarative system configuration
- **Podman** — container runtime
- **ZFS** — storage pool
- **Terraform** — infrastructure as code for DNS records
- **sops-nix** — encrypted secrets in version control
- **GitHub Actions** — CI/CD using self-hosted runner

## Deployment workflow

> The GitHub Actions runner runs on chaldea and deploys to itself — the host rebuilds its own configuration on every merge. Zero manual deployments.

### Cloud providers

- **Backblaze B2** — backup storage for restic
- **Tailscale** — VPN mesh network
- **Pangolin** — self-hosted VPS (unmanaged)
- **Cloudflare** — DNS management via Terraform

### CI/CD pipeline

The GitHub Actions runner executes **directly on chaldea itself**.

1. Pull requests trigger validation: formatting checks, flake correctness, and terraform plan
2. Terraform plan output is posted as a PR comment when DNS changes are detected
3. Merges to `main` trigger deployment: DNS updates followed by system configuration
4. PRs labeled with `skip-deploy` bypass the deployment step

**The entire system state is version controlled.** Rollback is achieved by reverting commits and re-deploying.

### GitHub configuration

Secrets and variables configured at the repository level:

| Name                        | Type     | Description                                 | Example                               |
| --------------------------- | -------- | ------------------------------------------- | ------------------------------------- |
| `AWS_ACCESS_KEY_ID`         | Secret   | Backblaze B2 access key for terraform state | `0001a2b3c4d5e6f7g8h9`                |
| `AWS_SECRET_ACCESS_KEY`     | Secret   | Backblaze B2 secret key for terraform state | `K001abcdefghijklmnopqrstuvwxyz`      |
| `CLOUDFLARE_API_TOKEN`      | Secret   | Cloudflare API token for DNS management     | `abc123...`                           |
| `SSH_PRIVATE_KEY`           | Secret   | Ed25519 private key for deployment          | `-----BEGIN OPENSSH PRIVATE KEY-----` |
| `TF_VAR_cloudflare_zone_id` | Variable | Cloudflare zone ID for DNS records          | `abc123def456ghi789jkl012mno345`      |
| `TF_VAR_tailscale_ip`       | Variable | Tailscale IP address of chaldea             | `100.x.y.z`                           |
| `TF_VAR_pangolin_ip`        | Variable | Public IP of pangolin VPS                   | `1.2.3.4`                             |

