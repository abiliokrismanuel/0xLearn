# generate bycri
https://hostingcanada.org/htpasswd-generator/

# port forward
kubectl port-forward svc/argocd-server -n argocd 8080:443

# exec 
mkubectl exec -it argocd-server -n argocd -- /bin/sh

# patch pw admin
kubectl -n argocd patch secret argocd-secret \
  -p '{"stringData": {
    "admin.password": "$2y$cobainF8Odcfn3DURDcJse.iZhehelxwalweeesoTKHra/mG4kiwkiwxQvFGcs0zlW",
    "admin.passwordMtime": "'$(date +%FT%T%Z)'"}}'


