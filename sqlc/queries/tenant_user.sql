-- name: CreateTenantUser :one
INSERT INTO tenant_user (
    tenant_id, is_active, external_id, email, preferred_username, locale, app_theme, hourly_rate, created_by, updated_by
) VALUES (
    $1, $2, $3, $4, $5, COALESCE($6, 'hr'), COALESCE($7, 'dark'), $8, $9, $10
)
RETURNING id, tenant_id, is_active, external_id, email, preferred_username, locale, app_theme, hourly_rate, created_at, updated_at, created_by, updated_by;

-- name: GetTenantUserByID :one
SELECT id, tenant_id, is_active, external_id, email, preferred_username, locale, app_theme, hourly_rate, created_at, updated_at, created_by, updated_by
FROM tenant_user
WHERE id = $1;

-- name: SetTenantUserActiveStatus :one
UPDATE tenant_user
SET is_active = $2,
    updated_at = now(),
    updated_by = $3
WHERE id = $1
RETURNING id, tenant_id, is_active, external_id, email, preferred_username, locale, app_theme, hourly_rate, created_at, updated_at, created_by, updated_by;

-- name: UpdateTenantUserProfile :one
UPDATE tenant_user
SET
    locale = COALESCE($2, locale),
    app_theme = COALESCE($3, app_theme),
    updated_at = now(),
    updated_by = $4
WHERE id = $1
RETURNING id, tenant_id, is_active, external_id, email, preferred_username, locale, app_theme, hourly_rate, created_at, updated_at, created_by, updated_by;

-- name: UpdateTenantUserHourlyRate :one
UPDATE tenant_user
SET
    hourly_rate = $2,
    updated_at = now(),
    updated_by = $3
WHERE id = $1
RETURNING id, tenant_id, is_active, external_id, email, preferred_username, locale, app_theme, hourly_rate, created_at, updated_at, created_by, updated_by;
