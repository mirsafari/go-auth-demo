### Depependencies

- https://github.com/go-chi/chi
- https://github.com/markbates/goth
- https://github.com/gorilla/sessions


### Development environment

Requirements:

- https://direnv.net/
- https://devenv.sh/ and [Automatic shell activation]

[Automatic shell activation]: https://devenv.sh/automatic-shell-activation/#configure-shell-activation


## Why X:

I want to use certs and have the service available outside of the cluster.
Therefore:

- https://minikube.sigs.k8s.io/docs/handbook/accessing/#loadbalancer-access
        - Each service will get its own external IP = Can't generate nip.ip cert
- https://k3d.io/stable/usage/advanced/podman/#macos
        - A bit more complicated and fragile MacOS setup
- https://kind.sigs.k8s.io/docs/user/ingress/
        - https://kind.sigs.k8s.io/docs/user/loadbalancer/ requires installing extra tool that deploys extra stuff  
        - Extra Port Mappings - multiple services on 80/443 by default, can't specify which container to forward 
