# Networking

Prerequisite: [SECRETS.md](https://github.com/ryanmalonzo/homelab/blob/main/docs/SECRETS.md)

## Install cert-manager

```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.21.0/cert-manager.yaml
```

## Configure secrets used by cert-manager

Both sealed in the `cert-manager` namespace (refer to the command in SECRETS.md):

- `cloudflare-api-token` (key `cloudflare-api-token`) — Cloudflare API token (Zone:DNS:Edit)
- `zerossl-eab-hmac` (key `zerossl-eab-hmac`) — ZeroSSL ACME External Account Binding HMAC key, generated from the ZeroSSL dashboard

## Set up the Tailscale subnet router

Run directly on the host.

```bash
curl -fsSL https://tailscale.com/install.sh | sh
```

Enable IP forwarding:

```bash
echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
echo 'net.ipv6.conf.all.forwarding = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
sudo sysctl -p /etc/sysctl.d/99-tailscale.conf
```

Bring the node up and advertise the LAN subnet (`192.168.1.0/24`, from `enp2s0`):

```bash
sudo tailscale up --advertise-routes=192.168.1.0/24
```

> [!IMPORTANT]
> Still required, done via the [admin console](https://login.tailscale.com/admin/machines), not the CLI:
>
> - Approve the advertised route on this machine (Machines page).
> - Restrict what the route actually exposes via a [grant](https://tailscale.com/docs/reference/syntax/grants) in the tailnet policy file — advertising `192.168.1.0/24` doesn't by itself permit reaching the whole LAN, but the default policy may need one added, e.g. limiting access to `192.168.1.35:443` only.

### Linux performance optimizations

Per [Tailscale's best practices](https://tailscale.com/docs/reference/best-practices/performance#linux-optimizations-for-subnet-routers-and-exit-nodes), enable UDP offloads on the LAN interface. Debian doesn't use `systemd-networkd`/`networkd-dispatcher`, so persistence across reboots is handled with a small systemd unit instead:

```ini
# /etc/systemd/system/tailscale-ethtool.service
[Unit]
Description=Apply ethtool offload settings for Tailscale subnet router
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/sbin/ethtool -K enp2s0 rx-udp-gro-forwarding on rx-gro-list off

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now tailscale-ethtool.service
```

## Expose Argo CD

Prerequisite: Argo CD installed per [ARGOCD.md](https://github.com/ryanmalonzo/homelab/blob/main/docs/ARGOCD.md).

`argocd-server` terminates its own TLS by default. Since Traefik is taking over TLS termination (via the cert-manager-issued certificate), `argocd-server` needs to run in insecure mode instead — handled declaratively by `k8s/manifests/argocd/config-map.yaml`, synced automatically by the `chaldea` Argo CD Application.

Kubernetes doesn't propagate a `ConfigMap` change into an already-running Pod, so one restart is required the first time this takes effect (safe to re-run, no-op if already applied):

```bash
kubectl rollout restart deployment argocd-server -n argocd
```

TLS and routing are handled by `k8s/manifests/argocd/certificate.yaml` and `ingress-route.yaml`. A Traefik `IngressRoute` is used here specifically because `argocd-server` multiplexes the web UI (HTTP) and CLI (gRPC) on the same port, distinguished by header — something a plain `Ingress` can't route on. Since cert-manager's `Ingress`-watching automation (`ingress-shim`) doesn't watch `IngressRoute`, the `Certificate` is created explicitly instead of via annotation.
