[group('Local OS configuration')]
[doc('Add generated self-singed certificate to local truststore')]
add-selfsigned-ca-to-truststore: configure-kubectl-context
  #!/usr/bin/env bash
  set -euo pipefail

  kubectl wait -n keycloak --for=create secret/keycloak-https-certificate --timeout=180s

  # Get all ingress hostnames and their associated TLS secrets
  kubectl get ingress --all-namespaces -o json | jq -r '
    .items[] 
    | select(.spec.tls != null) 
    | [.metadata.namespace, (.spec.tls[] | .hosts[], .secretName)] 
    | @tsv' | while read -r namespace hostname secret; do

  echo "Processing host: $hostname in namespace: $namespace, secret: $secret"
  cert_data=$(kubectl get secret "$secret" -n "$namespace" -o jsonpath='{.data.ca\.crt}' 2>/dev/null)

  if [[ -z "$cert_data" ]]; then
    echo "❌ No CA found in secret $secret in namespace $namespace"
    continue
  fi

  ca_file="/tmp/temp-cert-manager-$hostname.ca"
  echo "$cert_data" | base64 --decode > "$ca_file"

  if security find-certificate -c "$hostname" /Library/Keychains/System.keychain > /dev/null 2>&1; then
    echo "✅ Certificate for $hostname already exists in system keychain"
  else
    echo "🔐 Adding certificate for $hostname to system keychain..."
    sudo security add-trusted-cert -d -r trustRoot -p ssl -p codeSign -k /Library/Keychains/System.keychain "$ca_file"
  fi

  rm "$ca_file"
  done

[group('Local OS configuration')]
[doc('Remove generated self-singed certificate from local truststore')]
remove-selfsigned-ca-from-truststore: configure-kubectl-context
  #!/usr/bin/env bash
  set -euo pipefail

  kubectl get ingress --all-namespaces -o json | jq -r '
    .items[] 
    | select(.spec.tls != null) 
    | select(.spec.tls != null)
    | [(.spec.tls[] | .hosts[])]
    | @tsv' | while read -r hostname; do

  echo "🗑️ Removing cert for $hostname"
  sudo security delete-certificate -t -c "$hostname" /Library/Keychains/System.keychain 2>/dev/null \
    && echo "✅ Removed: $hostname" \
    || echo "⚠️ Couldn't delete certificate for: $hostname. Check KeyChain manually"
  sleep 3
  done

[group('Local OS configuration')]
[doc('Exposes Ingress controller locally')]
expose-services-tmux: add-selfsigned-ca-to-truststore
  curl -s -f -LI https://keycloak.127.0.0.1.nip.io/admin/master/console/ | grep 200 || tmux new-window "echo 'Enter sudo password to tunnel connections to cluster' && minikube tunnel"

[group('Get information')]
[doc('Get Keycloak admin credentials')]
get-keycloak-admin-credentials: configure-kubectl-context
  kubectl wait -n keycloak --for=create secret/keycloak-boostrap-admin-credentials --timeout=180s
  @echo "Connect to Keycloak on: "
  @echo "URL: $(kubectl -n keycloak get ingress keycloak-nip-io -o jsonpath='{.spec.rules[0].host}')"
  @echo "User: $(kubectl get secrets -n keycloak keycloak-boostrap-admin-credentials -o jsonpath='{.data.username}' | base64 -d)"
  @echo "Pass: $(kubectl get secrets -n keycloak keycloak-boostrap-admin-credentials -o jsonpath='{.data.password}' | base64 -d)"
