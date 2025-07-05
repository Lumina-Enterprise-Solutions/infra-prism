-- infra/migrations/000018_add_multi_tenancy.down.sql
-- FASE 3: REVERT IMPLEMENTASI MULTI-TENANCY PENUH

-- Step 1: Revert changes to `organizations` table
COMMENT ON TABLE organizations IS NULL;
ALTER TABLE organizations RENAME COLUMN tenant_id TO id;
ALTER TABLE organizations DROP COLUMN domain;

-- Step 2: Revert changes to `users` table
DROP INDEX idx_users_tenant_email_unique;
CREATE UNIQUE INDEX users_email_key ON users (email);
DROP INDEX idx_users_tenant_id;
ALTER TABLE users DROP CONSTRAINT fk_user_tenant;
ALTER TABLE users ADD COLUMN organization_id UUID;
UPDATE users u SET organization_id = o.id FROM organizations o WHERE u.tenant_id = o.id;
ALTER TABLE users DROP COLUMN tenant_id;
ALTER TABLE users ADD CONSTRAINT fk_user_organization FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE;
ALTER TABLE users ALTER COLUMN organization_id SET NOT NULL;
COMMENT ON COLUMN users.tenant_id IS NULL;

-- Step 3: Revert changes to `teams` table
DROP INDEX idx_teams_tenant_id;
ALTER TABLE teams DROP CONSTRAINT fk_team_tenant;
ALTER TABLE teams ADD COLUMN organization_id UUID;
UPDATE teams t SET organization_id = o.id FROM organizations o WHERE t.tenant_id = o.id;
ALTER TABLE teams DROP COLUMN tenant_id;
ALTER TABLE teams ADD CONSTRAINT fk_team_organization FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE;
ALTER TABLE teams ALTER COLUMN organization_id SET NOT NULL;
CREATE INDEX idx_teams_organization_id ON teams(organization_id);

-- Step 4: Revert changes to `files` and `api_keys` tables
DROP INDEX idx_files_tenant_id;
ALTER TABLE files DROP COLUMN tenant_id;
DROP INDEX idx_api_keys_tenant_id;
ALTER TABLE api_keys DROP COLUMN tenant_id;
