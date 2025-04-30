# path token
/var/lib/rancher/k3s/server/node-token

exp : K10de6604060764950hehebe633591a8ftestingajaasodhiaugdsqw7147bdf7a315699da00ebeb::server:33cc1080034c6testingajaaoisndhioa252

token setelah ::server -> 33cc1080034c6testingajaaoisndhioa252

# backup etcd k3s stacked 

k3s etcd-snapshot save --name backup-test --dir /home/ubuntu/backup/

# delete

kubectl delete all -l app=frontend -n default  -> label

# cek ingress

kubectl get ingress -A
kubectl describe ingress <nama-ingress> -n <namespace>
