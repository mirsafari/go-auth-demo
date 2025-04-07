default:
  just --list

export DEV_CLUSTER_NAME := "local-dev-cluster"
export KEYCLOAK_OPERATOR_VERSION := "26.1.4"
export KEYCLOAK_OPERATOR_NAMESPACE := "keycloak-operator"
export KEYCLOAK_DOMAIN := "keycloak.127.0.0.1.nip.io"
export CLOUDNATIVE_PG_VERSION :="1.25.1"
export INGRESS_VERSION := "v1.12.1"
export CPUS := "4"
export MEMORY_MB := "3072"

[group('0) Local development')]
[doc('Setup, start and initialize local development cluster')]
start-dev: && start-podman start-k8s configure-k8s-cluster-deps add-selfsigned-ca-to-truststore

[group('0) Local development')]
[doc('Stop local Kubernetes cluster and underlying VM')]
stop-dev: && stop-k8s stop-podman

[group('0) Local development')]
[doc('Remoev local Kubernetes cluster and underlying VM')]
cleanup-dev: && delete-k8s delete-podman-machine remove-selfsigned-ca-to-truststore

[group('Setup')]
[doc('Starts Podman machine')]
start-podman:
  echo "Creating podman machine ..."
  podman machine list --format "{{{{.Name}}" | grep -q "^podman-machine-default\*$" || podman machine init --cpus ${CPUS} --memory ${MEMORY_MB};

  echo "Starting podman machine ..."
  podman machine list | grep "Currently running" || podman machine start

[group('Setup')]
[doc('Start local K8S cluster')]
start-k8s: start-podman
  @echo "Starting k8s cluster ..."
  minikube config set rootless true
  minikube status | grep -q "apiserver: Running" || minikube start --driver=podman --container-runtime=containerd --cpus ${CPUS} --memory "no-limit";
  kubectl get deployments.apps -n yakd-dashboard | grep -q yakd-dashboard || minikube addons enable yakd
  kubectl get deployments.apps -n kube-system | grep metrics-server || minikube addons enable metrics-server	

  @echo "Ensuring kube-context is configured ..."
  kubectl config current-context | grep "minikube" || kubectl config set-context minikube
  kubectl cluster-info | grep 127.0.0.1

[group('Setup')]
[doc('Deploys Keycloak, Keycloak Operator, Ingress controller, CloudNativePG, PostgreSQL to KinD cluster')]
configure-k8s-cluster-deps:
  (r=5;while ! kubectl apply --server-side -k ./infra/manifests/local ; do ((--r))||exit;echo "Waiting for admission to start. Retrying in 60s ..." && sleep 60;done)

[group('Pause')]
[doc('Stops local K8S cluster')]
stop-k8s:
  minikube stop

[group('Pause')]
[doc('Stops Podman machine')]
stop-podman:
  echo "Stopping podman machine"
  podman machine stop

[group('Cleanup')]
[doc('Removes local K8S cluster')]
delete-k8s:
  minikube delete

[group('Cleanup')]
[doc('Removes Podman machine')]
delete-podman-machine:
  echo "Stopping podman machine"
  podman machine rm podman-machine-default -f

[group('Setup')]
[doc('Add generated self-singed certificate to local truststore')]
add-selfsigned-ca-to-truststore:
  kubectl wait -n keycloak --for=create secret/keycloak-https-certificate --timeout=180s
  @echo "Getting the CA generated by cert-manager and storing it to local Trust Store"
  @echo "Confirm to continue .."
  kubectl -n keycloak get secrets keycloak-https-certificate -o jsonpath='{.data.ca\.crt}' | base64 -d > /tmp/temp-cert-manager.ca && \
  sudo security add-trusted-cert -d -r trustRoot -p ssl -p codeSign -k /Library/Keychains/System.keychain /tmp/temp-cert-manager.ca && \
  rm /tmp/temp-cert-manager.ca

[group('Cleanup')]
[doc('Remove generated self-singed certificate from local truststore')]
remove-selfsigned-ca-to-truststore:
  @echo "Removing from truststore"
  sudo security delete-certificate -t -c ${KEYCLOAK_DOMAIN} /Library/Keychains/System.keychain


[group('Setup')]
[doc('Exposes Ingress controller locally')]
expose-services-tmux: add-selfsigned-ca-to-truststore
  kubectl wait -n keycloak --for=create secret/local-dev-initial-admin --timeout=180s
  @echo "Connect to Keycloak on: "
  @echo "URL: ${KEYCLOAK_DOMAIN}"
  @echo "User: $(kubectl get secrets -n keycloak local-dev-initial-admin -o jsonpath='{.data.username}' | base64 -d)"
  @echo "Pass: $(kubectl get secrets -n keycloak local-dev-initial-admin -o jsonpath='{.data.password}' | base64 -d)"
  tmux new-window "echo 'Enter sudo password to tunnel connections to cluster' && minikube tunnel"
