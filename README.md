# chaldea

![healthchecks.io](https://healthchecks.io/badge/261911a0-3c4a-4c11-b500-6330b0/8-eeEdAn-2.svg)

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

> The GitHub Actions runner runs on chaldea and deploys to itself. The host rebuilds its own configuration on every merge. Zero manual deployments.

### Cloud providers

- **Backblaze B2** — backup storage for restic
- **Tailscale** — VPN mesh network
- **Pangolin** — self-hosted VPS (unmanaged)
- **Cloudflare** — DNS management via Terraform
- **Healthchecks.io** —  heartbeat monitor for Gatus

### CI/CD pipeline

The GitHub Actions runner executes **on chaldea itself**.

1. Pull requests trigger validation: formatting checks, flake correctness, and terraform plan
2. Terraform plan output is posted as a PR comment when DNS changes are detected
3. Merges to `main` trigger deployment: DNS updates followed by system configuration
4. PRs labeled with `skip-deploy` bypass the deployment step

**The entire system state is version controlled.**

## Adding a new service

### Internal service (behind Tailscale)

**1. Create `services/<name>.nix`**

```nix
{ ... }:

{
  systemd.tmpfiles.rules = [
    "d /srv/<name>/data 0755 1000 100 -"
  ];

  virtualisation.oci-containers.containers.<name> = {
    image = "image/name:tag";
    networks = [ "<name>" ];
    ports = [ "<host-port>:<container-port>" ];
    volumes = [
      "/srv/<name>/data:/data"
    ];
    environment = {
      TZ = "Europe/Paris";
    };
  };

  systemd.services."podman-<name>".after = [ "podman-network-<name>.service" ];
  systemd.services."podman-<name>".requires = [ "podman-network-<name>.service" ];
}
```

**2. Add the network — `modules/container-networks.nix`**

```nix
  networks = [
    ...
    "<name>"
  ];
```

**3. Add the Caddy virtual host — `modules/caddy.nix`**

```nix
virtualHosts = {
  ...
  "<name>.internal.chaldea.dev" = {
    extraConfig = ''
      ${tlsConfig}
      reverse_proxy localhost:<host-port>
    '';
  };
};
```

**4. Import the module — `flake.nix`**

```nix
modules = [
  ...
  ./services/<name>.nix
];
```

### Public service

**1. Create `services/<name>.nix`**

```nix
{ ... }:

{
  virtualisation.oci-containers.containers.<name> = {
    image = "image/name:tag";
    networks = [ "proxy" ];
  };

  systemd.services."podman-<name>".after = [ "podman-network-proxy.service" ];
  systemd.services."podman-<name>".requires = [ "podman-network-proxy.service" ];
}
```

**2. Add a CNAME record — `terraform/main.tf`**

```hcl
  cname_subdomains = [
    ...
    "<name>"
  ]
```

**3. Import the module — `flake.nix`**

```nix
modules = [
  ...
  ./services/<name>.nix
];
```

### Adding a sops secret

**1. Add the plaintext value to `secrets/secrets.yaml`**

```sh
sops secrets/secrets.yaml
```

**2. Reference the secret in the service**

```nix
{ config, ... }:

{
  sops.secrets.<secret-name> = { };

  sops.templates."<name>-env" = {
    content = ''
      ENV_VAR=${config.sops.placeholder.<secret-name>}
    '';
  };

  virtualisation.oci-containers.containers.<name> = {
    ...
    environmentFiles = [ config.sops.templates."<name>-env".path ];
  };

  # Restart the container when the secret changes
  systemd.services."podman-<name>".restartTriggers = [
    config.sops.templates."<name>-env".file
  ];
}
```

### Adding a Gatus monitor

Add an endpoint to the `endpoints` list in `services/gatus.nix`:

```nix
endpoints = [
  ...
  {
    name = "<Name>";
    group = "<group>";
    url = "https://<name>.internal.chaldea.dev";
    interval = "30s";
    conditions = [ "[STATUS] == 200" ];
    alerts = [ { type = "ntfy"; } ];
  }
];
```

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

