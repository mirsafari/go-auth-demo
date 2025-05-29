-- name: CreateTenant :one
INSERT INTO tenants (name, email_domain, is_active, created_by, updated_by)
VALUES ($1, $2, $3, $4, $5)
RETURNING id, name, email_domain, is_active, created_at, updated_at, created_by, updated_by;

-- name: GetTenantByID :one
SELECT id, name, email_domain, is_active, created_at, updated_at, created_by, updated_by
FROM tenants
WHERE id = $1;

-- name: ListTenants :many
SELECT id, name, email_domain, is_active, created_at, updated_at, created_by, updated_by
FROM tenants
ORDER BY created_at DESC;

-- name: UpdateTenant :one
UPDATE tenants
SET
    name = COALESCE($2, name),
    email_domain = COALESCE($3, email_domain),
    is_active = COALESCE($4, is_active),
    updated_at = now(),
    updated_by = $5
WHERE id = $1
RETURNING id, name, email_domain, is_active, created_at, updated_at, created_by, updated_by;
