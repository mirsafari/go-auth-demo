resource "keycloak_user" "bob" {
  realm_id = keycloak_realm.realm.id
  username = "bob@domain.com"
  enabled  = true

  first_name     = "Bob"
  last_name      = "Bobson"
  email          = "bob@domain.com"
  email_verified = true

  initial_password {
    value     = "Password123"
    temporary = false
  }

}

resource "keycloak_group" "tenant_admin" {
  realm_id = keycloak_realm.realm.id
  name     = "tenant-admin"
}

resource "keycloak_group_memberships" "tenant_admin_members" {
  realm_id = keycloak_realm.realm.id
  group_id = keycloak_group.tenant_admin.id

  members  = [
    keycloak_user.bob.username
  ]
}
