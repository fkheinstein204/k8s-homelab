## Install and Configure Vault

### Install vault with Helm

```bash
helm repo add hashicorp https://helm.releases.hashicorp.com
helm search repo hashicorp/vault
helm install vault hashicorp/vault --namespace vault --create-namespace
kubectl get all --namespace vault
```

### Initial

```bash
kubectl exec --namespace='vault' vault-0 -- vault operator init
```

### Unseal Key
```bash
kubectl exec --namespace='vault' vault-0 -- vault operator unseal <UnsealKey1>
kubectl exec --namespace='vault' vault-0 -- vault operator unseal <UnsealKey2>
kubectl exec --namespace='vault' vault-0 -- vault operator unseal <UnsealKey3>


$ kubectl -n vault exec -it vault-0 -- vault operator unseal
$ kubectl -n vault exec -it vault-0 -- vault operator unseal
$ kubectl -n vault exec -it vault-0 -- vault operator unseal
$ kubectl -n vault exec -ti vault-1 -- vault operator raft join http://vault-0.vault-internal:8200
$ kubectl -n vault exec -it vault-1 -- vault operator unseal
$ kubectl -n vault exec -it vault-1 -- vault operator unseal
$ kubectl -n vault exec -it vault-1 -- vault operator unseal
$ kubectl -n vault exec -ti vault-2 -- vault operator raft join http://vault-0.vault-internal:8200
$ kubectl -n vault exec -it vault-2 -- vault operator unseal
$ kubectl -n vault exec -it vault-2 -- vault operator unseal
$ kubectl -n vault exec -it vault-2 -- vault operator unseal

```


### Check Status

```bash
kubectl exec --namespace='vault' vault-0 -- vault status
```

### Login into Vault

```bash
kubectl exec --namespace='vault' vault-0 -- vault login <RootToken>
```

### Enable Secret Engines

```bash
kubectl exec --namespace='vault' vault-0 -- vault secrets enable -path=secret kv-v2
kubectl exec --namespace='vault' vault-0 -- vault kv put secret/mysecret value="my-secret"
```

###  Enable Kubernetes Authentication in Vault

```bash
kubectl exec --namespace='vault' vault-0 -- vault auth enable kubernetes
```

### Configure Vault with Kubernetes Auth Method

```bash
kubectl create serviceaccount vault-auth

KUBERNETES_HOST=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')
echo $KUBERNETES_HOST

kubectl config view --raw -o jsonpath='{.clusters[0].cluster.certificate-authority-data}' | base64 --decode > ca.crt
```

```bash
kubectl exec --namespace='vault' vault-0 -- vault write auth/kubernetes/config \
  kubernetes_host="$KUBERNETES_HOST" \
  kubernetes_ca_cert=@/path/to/ca.crt
```

vault policy write internal-app - <<EOF
 path "internal/data/database/config" {
 capabilities = ["read"]
 }
EOF

vault write auth/kubernetes/role/internal-app \
  bound_service_account_names=internal-app \
  bound_service_account_namespaces=default \
  policies=internal-app \
  ttl=24h


### PostgreSQL

```bash
kubectl get configmap vault-config -n vault -o yaml > vault.yaml
helm upgrade vault hashicorp/vault -f vault.yaml --namespace vault
```