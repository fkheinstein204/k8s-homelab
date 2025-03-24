
Debugging 

```bash

kubectl exec -it $POD_NAME -n hbr-keycloak -- psql -h localhost -U postgres --password -p 5432 keycloak

```


Create secret for credentials

```bash

# create the unencrypted secret
 kubectl create -n keycloak -o yaml --dry-run=client secret generic postgresql-keycloak-credentials \
 --from-literal=password=$(openssl rand -base64 32) > secrets/raw/postgresql-keycloak-credentials.yaml


 kubectl create -n keycloak -o yaml --dry-run=client secret generic keycloak-admin-password \
 --from-literal=password=$(openssl rand -base64 16) > secrets/raw/keycloak-admin-credentials.yaml


# seal it
 kubeseal --controller-name=sealed-secrets --controller-namespace=kube-system --secret-file secrets/raw/keycloak-admin-credentials.yaml --sealed-secret-file secrets/keycloak-admin-credentials-sealed.yaml



CREATE DATABASE keycloak;
CREATE USER keycloak WITH ENCRYPTED PASSWORD 'IHJ+85cZttwhb20T09sdsXwG5vpjWt0b/4f7PxvwWcPHOE=';
GRANT ALL PRIVILEGES ON DATABASE keycloak TO keycloak;
ALTER DATABASE keycloak OWNER TO keycloak;

```