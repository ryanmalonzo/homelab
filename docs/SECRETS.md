# Secrets

## Install Sealed Secrets

Follow instructions listed [here](https://github.com/bitnami/sealed-secrets/releases#release-v0.38.4)

Example usage:

```bash
kubectl create secret generic cloudflare-api-token -n cert-manager --from-literal=cloudflare-api-token=<CLOUDFLARE_API_TOKEN> --dry-run=client -o yaml | kubeseal --format yaml > cloudflare-api-token.yaml
```

> [!IMPORTANT]
> `kubectl` on the host must be able to reach the cluster (see [SETUP.md](https://github.com/ryanmalonzo/homelab/blob/main/docs/SETUP.md))

## Back up private keys

```bash
kubectl get secret -n kube-system -l sealedsecrets.bitnami.com/sealed-secrets-key -o yaml >main.key
```

## Restore

```bash
kubectl apply -f main.key
kubectl delete pod -n kube-system -l name=sealed-secrets-controller
```
