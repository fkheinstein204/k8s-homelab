

```bash

# prepare credentials secret

kubectl get namespaces database > /dev/null 2>&1 || kubectl create namespace database
kubectl -n database create secret generic mariadb-credentials \
    --from-literal=mariadb-root-password=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 16) \
    --from-literal=mariadb-replication-password=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 16) \
    --from-literal=mariadb-password=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 16)

 kubeseal --controller-name=sealed-secrets --controller-namespace=kube-system  \
  --format yaml < mariadb-credentials.yaml > mariadb-credentials-sealed.yaml

```


tests with cli


1. with root user

```bash

ROOT_PASSWORD=$(kubectl -n database get secret mariadb-credentials -o jsonpath='{.data.mariadb-root-password}' | base64 -d)
podman run --rm \
    -e MYSQL_PWD=${ROOT_PASSWORD} \
    -it docker.io/library/mariadb:11.2.2-jammy \
    mariadb \
    --host host.containers.internal \
    --port 32306 \
    --user root \
    --database mysql \
    --execute 'show databases'

docker run -p 127.0.0.1:3306:3306  --name mdb -e MARIADB_ROOT_PASSWORD=${ROOT_PASSWORD} -d mariadb:latest

docker run -it --link some-mariadb:mysql --rm mariadb sh -c 'exec mysql -h"$MYSQL_PORT_3306_TCP_ADDR" -P"$MYSQL_PORT_3306_TCP_PORT" -uroot -p"$MYSQL_ENV_MYSQL_ROOT_PASSWORD"'
```


2. with normal user

```bash

PASSWORD=$(kubectl -n database get secret mariadb-credentials -o jsonpath='{.data.mariadb-password}' | base64 -d)
podman run --rm \
    -e MYSQL_PWD=${PASSWORD} \
    -it docker.io/library/mariadb:11.2.2-jammy \
    mariadb \
    --host host.containers.internal \
    --port 32306 \
    --user ben.wangz \
    --database geekcity \
    --execute 'show databases'

```




```bash

server: mariadb.database:3306
username: root
password:

kubectl -n database get secret mariadb-credentials -o jsonpath='{.data.mariadb-root-password}' | base64 -d

```


```bash

username: wheezy.fts
kubectl -n database get secret mariadb-credentials -o jsonpath='{.data.mariadb-password}' | base64 -d

```