-- infra/migrations/000018_add_multi_tenancy.up.sql
-- FASE 3: IMPLEMENTASI MULTI-TENANCY PENUH

-- Step 1: Ubah tabel `organizations` agar bisa berfungsi sebagai tabel `tenants`
COMMENT ON TABLE organizations IS 'Stores tenant information. Each organization is a separate tenant in the system.';
ALTER TABLE organizations RENAME COLUMN id TO tenant_id;
ALTER TABLE organizations ADD COLUMN domain VARCHAR(255) UNIQUE;
COMMENT ON COLUMN organizations.domain IS 'Optional custom domain for the tenant.';

-- Step 2: Tambahkan kolom tenant_id ke tabel `users`
ALTER TABLE users ADD COLUMN tenant_id UUID;
UPDATE users u SET tenant_id = o.tenant_id FROM organizations o WHERE u.organization_id = o.tenant_id;
ALTER TABLE users DROP COLUMN organization_id; -- Hapus kolom lama
ALTER TABLE users ADD CONSTRAINT fk_user_tenant FOREIGN KEY (tenant_id) REFERENCES organizations(tenant_id) ON DELETE CASCADE;
ALTER TABLE users ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX idx_users_tenant_id ON users(tenant_id);
-- Email harus unik per-tenant, bukan secara global lagi
DROP INDEX IF EXISTS users_email_key;
CREATE UNIQUE INDEX idx_users_tenant_email_unique ON users (tenant_id, email);
COMMENT ON COLUMN users.tenant_id IS 'The tenant to which this user belongs.';

-- Step 3: Tambahkan kolom tenant_id ke tabel `teams`
ALTER TABLE teams ADD COLUMN tenant_id UUID;
UPDATE teams t SET tenant_id = o.tenant_id FROM organizations o WHERE t.organization_id = o.tenant_id;
ALTER TABLE teams DROP COLUMN organization_id; -- Hapus kolom lama
ALTER TABLE teams ADD CONSTRAINT fk_team_tenant FOREIGN KEY (tenant_id) REFERENCES organizations(id) ON DELETE CASCADE;
ALTER TABLE teams ALTER COLUMN tenant_id SET NOT NULL;
DROP INDEX IF EXISTS idx_teams_organization_id;
CREATE INDEX idx_teams_tenant_id ON teams(tenant_id);

-- Step 4: Tambahkan kolom tenant_id ke tabel lain yang memerlukan isolasi data
-- Contoh: `files` dan `api_keys`
ALTER TABLE files ADD COLUMN tenant_id UUID REFERENCES organizations(id);
ALTER TABLE api_keys ADD COLUMN tenant_id UUID REFERENCES organizations(id);

CREATE INDEX idx_files_tenant_id ON files(tenant_id);
CREATE INDEX idx_api_keys_tenant_id ON api_keys(tenant_id);
