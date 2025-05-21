[group('Kubernetes platform applications')]
[doc('Configure kubectl context')]
configure-kubectl-context:
  kubectl config current-context | grep "minikube" || kubectl config set-context minikube

[group('Kubernetes platform applications')]
[doc('Deploys Keycloak Operator, Ingress controller, CloudNativePG and Cert-Manager cluster')]
install-k8s-platform-services: configure-kubectl-context
  (r=5;while ! kubectl apply --server-side -k ./infra/manifests/local/platform-services; do ((--r))||exit;echo "Waiting for admission to start. Retrying in 60s ..." && sleep 60;done)
  @echo "✅ Instalation succesfully finished"

[group('Kubernetes platform applications')]
[doc('Deploys PostgreSQL database, Keycloak and ClusterIssuer')]
install-k8s-application-dependencies: configure-kubectl-context
  (r=3;while ! kubectl apply --server-side -k ./infra/manifests/local/application-dependencies; do ((--r))||exit;echo "Waiting for apps to start. Retrying in 30s ..." && sleep 30;done)
  @echo "✅ Instalation succesfully finished"

[group('Application setup')]
[doc('Configure Keycloak')]
configure-keycloak:
  @echo "Checking if Keycloak is up and running Terraform"
  kubectl -n keycloak get pod local-dev-0 -o jsonpath='{.status.phase}' | grep Running
  curl -s -f -LI https://keycloak.127.0.0.1.nip.io/admin/master/console/ | grep 200

  test -d ./infra/keycloak-config/.terraform || tofu -chdir=./infra/keycloak-config init -upgrade
  tofu -chdir=./infra/keycloak-config apply -auto-approve
  @echo "✅ Keycloak succesfully configured"


[group('Application setup')]
[doc('Prepare manifests with required configuration')]
prepare-application-manifests: configure-kubectl-context
  #!/usr/bin/env bash
  set -euo pipefail
  INGRESS_LB_SVC_IP=$(kubectl -n ingress-nginx get services ingress-nginx-controller -o jsonpath='{.spec.clusterIP}')
  OIDC_PROVIDER_URL=$(kubectl -n keycloak get ingress keycloak-nip-io -o jsonpath='{.spec.rules[0].host}')

  OIDC_CLIENT_ID=$(tofu -chdir=./infra/keycloak-config output oidc_client_id | tr -d '"' | tr -d '[:space:]' | base64)
  OIDC_CLIENT_SECRET=$(tofu -chdir=./infra/keycloak-config output oidc_client_secret | tr -d '"' | tr -d '[:space:]' | base64 )
  OIDC_PROVIDER_CA=$(kubectl -n keycloak get secrets keycloak-https-certificate -o jsonpath='{.data.ca\.crt}')

  cp ./infra/manifests/local/application/my-app-secrets.yaml.tmpl ./infra/manifests/local/application/my-app-secrets.yaml
  cp ./infra/manifests/local/application/kustomization.yaml.tmpl ./infra/manifests/local/application/kustomization.yaml

  sed -i "s/_NGINX_INGRESS_LB_IP_PLACEHOLDER_/$INGRESS_LB_SVC_IP/g" ./infra/manifests/local/application/kustomization.yaml
  sed -i "s/_KEYCLOAK_DOMAIN_PLACEHOLDER_/$OIDC_PROVIDER_URL/g" ./infra/manifests/local/application/kustomization.yaml

  sed -i "s/_OIDC_CLIENT_ID_PLACEHOLDER_/$OIDC_CLIENT_ID/g" ./infra/manifests/local/application/my-app-secrets.yaml
  sed -i "s/_OIDC_CLIENT_SECRET_PLACEHOLDER_/$OIDC_CLIENT_SECRET/g" ./infra/manifests/local/application/my-app-secrets.yaml
  sed -i "s/_OIDC_PROVIDER_CA_PLACEHOLDER_/$OIDC_PROVIDER_CA/g" ./infra/manifests/local/application/my-app-secrets.yaml

  echo "✅ Configuration prepared"

[group('Application setup')]
[doc('Deploys application to Kubernetes cluster')]
install-application-to-k8s: prepare-application-manifests
  (r=3;while ! kubectl apply --server-side -k ./infra/manifests/local/application; do ((--r))||exit;echo "Waiting for apps to start. Retrying in 30s ..." && sleep 30;done)
  @echo "✅ Instalation succesfully finished"
