#!/bin/bash

set -eux

REPO_ROOT=$(git rev-parse --show-toplevel)
SCRIPT_DIR=$(cd $(dirname $0); pwd)


message() {
  echo -e "\n######################################################################"
  echo "# $1"
  echo "######################################################################"
}

installArgoCd() {
  message "installing argoCD Helm Chart"

  if [ -z "$GITHUB_TOKEN" ]; then
    echo "GITHUB_TOKEN is not set!"
    exit 1
  fi

  if [ -z "$GITHUB_USER" ]; then
    echo "GITHUB_USER is not set!"
    exit 1
  fi



  cd $REPO_ROOT/argocd || exit
  helm repo add argo-cd https://argoproj.github.io/argo-helm
  helm repo update



  kubectl create namespace argocd

  kubectl -n argocd create secret generic deployment-git-repo-credentials --from-literal=username=$GITHUB_USER --from-literal=password=$GITHUB_TOKEN

  helm upgrade --install --wait --timeout 15m --atomic --namespace argocd --create-namespace \
    --repo https://argoproj.github.io/argo-helm argocd argo-cd --values - <<EOF
dex:
  enabled: false

configs:
  params:
    server.insecure: true

  cm:
    timeout.reconciliation: 60s

server:
  # -- The number of server pods to run
  replicas: 1

  logLevel: debug

  metrics:
    enabled: true

  extraArgs:
    - --insecure

repoServer:
  metrics:
    enabled: true
EOF

  kubectl apply -f ${SCRIPT_DIR}/manifests/project.yaml

  message "argoCD Helm Chart is Ready"

}


initArgo() {
  message "Setting up argoCD"

  cd $REPO_ROOT || exit

  helm template apps/ | kubectl apply -f -
}



installArgoCd
initArgo

message "all done!"
kubectl get nodes -o=wide

kubectl apply -f ${SCRIPT_DIR}/manifests/namespaces/devops.yaml