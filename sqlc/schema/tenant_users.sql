CREATE TABLE tenant_user (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,

    is_active BOOLEAN NOT NULL DEFAULT true,
    external_id TEXT NOT NULL, -- from OIDC provider
    email TEXT NOT NULL,
    preferred_username TEXT,
    locale TEXT NOT NULL DEFAULT 'hr',
    app_theme TEXT NOT NULL DEFAULT 'dark',
    hourly_rate REAL NOT NULL DEFAULT 0.0,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by TEXT NOT NULL,
    updated_by TEXT NOT NULL,

    -- Enforce uniqueness of email and external_id per tenant
    CONSTRAINT unique_tenant_email UNIQUE (tenant_id, email),
    CONSTRAINT unique_tenant_external_id UNIQUE (tenant_id, external_id)
);
