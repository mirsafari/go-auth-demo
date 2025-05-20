# Setup
export CPUS := "4"
export MEMORY_MB := "3072"

[group('Kubernetes Setup')]
[doc('Starts Podman machine')]
start-podman:
  echo "Creating podman machine ..."
  podman machine list --format "{{{{.Name}}" | grep -q "^podman-machine-default\*$" || podman machine init --cpus ${CPUS} --memory ${MEMORY_MB};

  echo "Starting podman machine ..."
  podman machine list | grep "Currently running" || podman machine start

  echo "✅ Podman succesfully started"

[group('Kubernetes Setup')]
[doc('Start local K8S cluster using Minikube')]
start-k8s: start-podman
  @echo "Starting k8s cluster ..."
  minikube config set rootless true
  minikube status | grep -q "apiserver: Running" || minikube start --driver=podman --container-runtime=containerd --cpus ${CPUS} --memory "no-limit";
  kubectl get deployments.apps -n yakd-dashboard | grep -q yakd-dashboard || minikube addons enable yakd
  kubectl get deployments.apps -n kube-system | grep metrics-server || minikube addons enable metrics-server	

  @echo "Ensuring kube-context is configured ..."
  kubectl config current-context | grep "minikube" || kubectl config set-context minikube
  kubectl cluster-info | grep 127.0.0.1

  echo "✅ Minikube succesfully started"

# Pause
[group('Kubernetes Pause')]
[doc('Stops local K8S cluster but does not delete it')]
stop-k8s:
  minikube stop

[group('Kubernetes Pause')]
[doc('Stops Podman machine but doesn not delete it')]
stop-podman: stop-k8s
  echo "Stopping podman machine"
  podman machine stop

# Deletion
[group('Kubernetes Cleanup')]
[doc('Removes local K8S cluster')]
delete-k8s:
  minikube delete

[group('Kubernetes Cleanup')]
[doc('Removes Podman machine')]
delete-podman-machine: delete-k8s
  echo "Stopping podman machine"
  podman machine rm podman-machine-default -f

