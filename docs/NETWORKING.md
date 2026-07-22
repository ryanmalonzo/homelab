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
