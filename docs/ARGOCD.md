# Argo CD

## Set current `kubectl` namespace to `argocd`

```bash
kubectl config set-context --current --namespace=argocd
```

## Temporarily forward Argo CD to port `8080`

```bash
kubectl port-forward svc/argocd-server -n argocd --address 0.0.0.0 8080:443
```

## Retrieve initial password

```bash
argocd admin initial-password -n argocd
```

## Log in to Argo CD

```bash
export ARGOCD_OPTS='--port-forward-namespace argocd'
# Use `admin` as username
argocd login <CLUSTER_LOCAL_IP>
argocd account update-password
```
