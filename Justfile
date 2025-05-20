import '.just/kubernetes-local-cluster.just'
import '.just/kubernetes-apps-install.just'
import '.just/post-install-operations.just'

default:
  just --list

[group('0) Oneliners')]
[doc('Create Kubernetes cluster')]
start-cluster: start-k8s

[group('0) Oneliners')]
[doc('Install apps')]
install-apps: && install-k8s-platform-services install-k8s-application-dependencies add-selfsigned-ca-to-truststore expose-services-tmux configure-keycloak prepare-application-manifests install-application-to-k8s

[group('0) Oneliners')]
[doc('Access services inside cluster')]
access-services: expose-services-tmux

[group('0) Oneliners')]
[doc('Shut down cluster whitout deleting applications')]
pause-development: stop-podman

[group('0) Oneliners')]
[doc('Cleanup')]
cleanup-dev: && remove-selfsigned-ca-from-truststore delete-podman-machine 
  rm ./infra/manifests/local/application/my-app-secrets.yaml
