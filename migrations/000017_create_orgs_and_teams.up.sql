-- File: infra/migrations/000017_create_org_and_teams_tables.up.sql

-- Tabel untuk Organisasi/Perusahaan
CREATE TABLE organizations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Tabel untuk Tim/Departemen di dalam sebuah organisasi
CREATE TABLE teams (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    department VARCHAR(100), -- Contoh atribut untuk ABAC (e.g., 'Finance', 'Engineering')
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(organization_id, name)
);

-- Tabel pivot untuk menghubungkan pengguna ke satu atau lebih tim
CREATE TABLE user_teams (
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    team_id UUID NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    PRIMARY KEY (user_id, team_id)
);

-- Tabel untuk mendefinisikan peran pengguna DALAM konteks sebuah tim
-- Ini memungkinkan seorang user menjadi 'manager' di satu tim dan 'viewer' di tim lain.
CREATE TABLE user_team_roles (
    user_id UUID NOT NULL,
    team_id UUID NOT NULL,
    role_id UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    PRIMARY KEY (user_id, team_id, role_id),
    FOREIGN KEY (user_id, team_id) REFERENCES user_teams(user_id, team_id) ON DELETE CASCADE
);

-- Tambahkan foreign key dari users ke organizations
ALTER TABLE users ADD COLUMN organization_id UUID REFERENCES organizations(id);

-- Indeks untuk performa query
CREATE INDEX idx_teams_organization_id ON teams(organization_id);
CREATE INDEX idx_users_organization_id ON users(organization_id);

COMMENT ON TABLE organizations IS 'Stores company or tenant information.';
COMMENT ON TABLE teams IS 'Stores teams or departments within an organization.';
COMMENT ON COLUMN teams.department IS 'An attribute for Attribute-Based Access Control (ABAC).';
COMMENT ON TABLE user_teams IS 'Pivot table linking users to their teams.';
COMMENT ON TABLE user_team_roles IS 'Defines a user''s specific role within a specific team.';
