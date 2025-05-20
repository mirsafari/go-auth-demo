[group('Keycloak setup')]
[doc('Create Keycloak realm and client')]
configure-keycloak:
  echo "Checking if Keycloak is up and running Terraform"
  curl -s -f -LI https://keycloak.127.0.0.1.nip.io/admin/master/console/ | grep 200

  test -d ./infra/keycloak-config/.terraform || tofu -chdir=infra/keycloak-config init -upgrade
  tofu -chdir=infra/keycloak-config apply -auto-approve

prepare-application-manifests:
  OIDC_CLIENT_ID=$(tofu -chdir=infra/keycloak-config output oidc_client_id)
  OIDC_CLIENT_SECRET=$(tofu -chdir=infra/keycloak-config output oidc_client_secret)
  OIDC_PROVIDER_URL=$(kubectl -n keycloak get ingress keycloak-nip-io -o jsonpath='{.spec.rules[0].host}')
  INGRESS_LB_SVC_IP=$(kubectl -n ingress-nginx get services ingress-nginx-controller -o jsonpath='{.spec.clusterIP}')

  sed -i "s/_NGINX_INGRESS_LB_IP_PLACEHOLDER/$INGRESS_LB_SVC_IP/g" ./../infra/manifests/local/kustomization.yaml

[doc('Setup OpenTofu')]
setup-opentofu:
