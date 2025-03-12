
### Redis Setup


Create secret for credentials

```bash

# create the unencrypted secret
 kubectl create -n database -o yaml --dry-run=client secret generic redis-credentials \
 --from-literal=redis-password=$(openssl rand -base64 16)  > secrets/raw/redis-credentials.yaml




# seal it
 kubeseal --controller-name=sealed-secrets --controller-namespace=kube-system --secret-file secrets/raw/redis-credentials.yaml --sealed-secret-file secrets/redis-credentials-sealed.yaml

```


tests

```bash

kubectl -n database exec -it deployment/redis-tool -- \
    redis-cli -c -h redis-master.database ping

kubectl -n database exec -it deployment/redis-tool -- \
    redis-cli -c -h redis-master.database set mykey somevalue

kubectl -n database exec -it deployment/redis-tool -- \
    redis-cli -c -h redis-master.database get mykey

kubectl -n database exec -it deployment/redis-tool -- \
    redis-cli -c -h redis-master.database del mykey

kubectl -n database exec -it deployment/redis-tool -- \
    redis-cli -c -h redis-master.database get mykey

```
