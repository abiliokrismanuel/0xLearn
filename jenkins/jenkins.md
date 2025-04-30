# helm add repo jenkins
helm repo add jenkins https://charts.jenkins.io
helm repo update

# create namespaces
kubectl create ns jenkins

# install jenkins helm
helm install jenkins jenkins/jenkins --namespace jenkins


# port forward

kubectl port-forward svc/jenkins -n jenkins 8080:8080

# wsl
netsh interface portproxy add v4tov4 listenport=30255 listenaddress=0.0.0.0 connectport=30255 connectaddress=[IP-WSL]

# known host 

ssh-keyscan github.com >> ~/.ssh/known_hosts

# notes
NOTES:
1. Get your 'admin' user password by running:
  kubectl exec --namespace jenkins -it svc/jenkins -c jenkins -- /bin/cat /run/secrets/additional/chart-admin-password && echo
2. Get the Jenkins URL to visit by running these commands in the same shell:
  echo http://127.0.0.1:8080
  kubectl --namespace jenkins port-forward svc/jenkins 8080:8080

3. Login with the password from step 1 and the username: admin
4. Configure security realm and authorization strategy
5. Use Jenkins Configuration as Code by specifying configScripts in your values.yaml file, see documentation: http://127.0.0.1:8080/configuration-as-code and examples: https://github.com/jenkinsci/configuration-as-code-plugin/tree/master/demos

For more information on running Jenkins on Kubernetes, visit:
https://cloud.google.com/solutions/jenkins-on-container-engine

For more information about Jenkins Configuration as Code, visit:
https://jenkins.io/projects/jcasc/


NOTE: Consider using a custom image with pre-installed plugins