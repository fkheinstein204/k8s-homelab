
### Postgresql Setup


Create secret for credentials

```bash

# create the unencrypted secret
 kubectl create -n database -o yaml --dry-run=client secret generic postgresql-credentials \
 --from-literal=postgres-password=$(openssl rand -base64 32) \
 --from-literal=replication-password=$(openssl rand -base64 32) \
 --from-literal=password=$(openssl rand -base64 32) > secrets/raw/postgresql-credentials.yaml




# seal it
 kubeseal --controller-name=sealed-secrets --controller-namespace=kube-system --secret-file secrets/raw/postgresql-credentials.yaml --sealed-secret-file secrets/postgresql-credentials-sealed.yaml

  # Option 2
 kubeseal --controller-name=sealed-secrets --controller-namespace=kube-system --format yaml < minio-credentials.yaml > minio-credentials-sealed.yaml

```


1. test root user

```bash
POSTGRES_PASSWORD=$(kubectl -n database get secret postgresql-credentials -o jsonpath='{.data.postgres-password}' | base64 -d)
podman run --rm \
    --env PGPASSWORD=${POSTGRES_PASSWORD} \
    --entrypoint psql \
    -it docker.io/library/postgres:15.2-alpine3.17 \
    --host host.containers.internal \ 
    --port 32543 \
    --username postgres \
    --dbname postgres \
    --command 'SELECT datname FROM pg_database;'
```

2. with normal user
```bash

POSTGRES_PASSWORD=$(kubectl -n database get secret postgresql-credentials -o jsonpath='{.data.password}' | base64 -d)
podman run --rm \
    --env PGPASSWORD=${POSTGRES_PASSWORD} \
    --entrypoint psql \
    -it docker.io/library/postgres:15.2-alpine3.17 \
    --host host.containers.internal \
    --port 32543 \
    --username ldap.fts20 \
    --dbname roomlab \
    --command 'SELECT datname FROM pg_database;'

```
