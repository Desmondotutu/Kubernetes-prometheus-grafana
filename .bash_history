
sudo apt update
sudo apt dist-upgrade -y
sudo apt update
sudo su -
clear
nanodeployment.yml
nano deployment.yml
kind delete cluster
kind create cluster --config deployment.yml
kubectl cluster-info --context kind-kind
kubectl get nodes
kubectl get services
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/main/bundle.yaml
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/main/bundle.yaml --force-conflicts=true --server-side=true
kubectl get deployments
nano prometheus_rbac.yaml
kubectl apply -f prometheus_rbac.yaml
nano prometheus_instance.yaml
kubectl apply -f prometheus_instance.yaml
kubectl get svc
kubectl port-forward svc/prometheus-operated 9090:9090
clear
exit
