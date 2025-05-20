terraform {
  required_providers {
    keycloak = {
      source = "keycloak/keycloak"
      version = ">= 5.0.0"
    }
  }
}

provider "keycloak" {
    client_id     = "admin-cli"
    username      = "admin"
    password      = "local-keycloak"
    url           = "https://keycloak.127.0.0.1.nip.io"
}
