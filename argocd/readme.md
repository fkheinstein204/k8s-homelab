

```bash


argocd login argocd.homelab.ftscode.de --insecure --username admin --password $ARGOCD_PASSWORD
argocd account update-password --account admin --current-password $ARGOCD_PASSWORD --new-password 'r3dh4t1!'

```