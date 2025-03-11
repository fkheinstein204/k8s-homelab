


```bash

kubectl create secret generic -n external-dns cloudflare-api-token --from-literal=apiToken=YOUR_CLOUD_FLARE_API_TOKEN --dry-run=client -o yaml


kubectl create secret generic -n cert-manager cloudflare-api-token --from-literal=apiToken=YOUR_CLOUD_FLARE_API_TOKEN --dry-run=client -o yaml

```