resource "keycloak_openid_client" "openid_client" {
  realm_id            = keycloak_realm.realm.id
  client_id           = "oauth-proxy-test"

  name                = "OAuth Proxy Test Client"
  enabled             = true

  access_type                  = "CONFIDENTIAL"
  standard_flow_enabled        = true
  direct_access_grants_enabled = false

  valid_redirect_uris = [
    "https://my-app.127.0.0.1.nip.io/oauth2/callback"
  ]
  login_theme = "keycloak"
}


resource "keycloak_openid_audience_protocol_mapper" "audience_mapper" {
  realm_id        = keycloak_realm.realm.id
  client_id       = keycloak_openid_client.openid_client.id
  name            = "aud-mapper-${keycloak_openid_client.openid_client.client_id}"

  included_client_audience = keycloak_openid_client.openid_client.client_id

  add_to_id_token     = true
  add_to_access_token = true
}

output "oidc_client_id" {
  value = keycloak_openid_client.openid_client.client_id
}
output "oidc_client_secret" {
  value = keycloak_openid_client.openid_client.client_secret
  sensitive = true
}
