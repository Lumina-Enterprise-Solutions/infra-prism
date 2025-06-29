-- Tabel untuk menyimpan peran
CREATE TABLE roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Tabel untuk menyimpan izin yang tersedia di sistem
CREATE TABLE permissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL UNIQUE, -- e.g., 'users:create', 'users:read', 'billing:manage'
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Tabel pivot untuk menghubungkan peran dan izin
CREATE TABLE role_permissions (
    role_id UUID NOT NULL,
    permission_id UUID NOT NULL,
    PRIMARY KEY (role_id, permission_id),
    CONSTRAINT fk_role FOREIGN KEY(role_id) REFERENCES roles(id) ON DELETE CASCADE,
    CONSTRAINT fk_permission FOREIGN KEY(permission_id) REFERENCES permissions(id) ON DELETE CASCADE
);

-- Modifikasi tabel 'users' untuk menggunakan foreign key ke tabel 'roles'
-- Ini adalah perubahan besar dari field 'role' yang berbasis string.
-- Pertama, buat peran default agar data yang ada tidak rusak.
INSERT INTO roles (name, description) VALUES ('admin', 'Administrator with all permissions'), ('user', 'Standard user with basic permissions');

-- Tambahkan kolom role_id baru
ALTER TABLE users ADD COLUMN role_id UUID;

-- Update role_id berdasarkan nilai string yang ada
UPDATE users SET role_id = (SELECT id FROM roles WHERE name = 'admin') WHERE role = 'admin';
UPDATE users SET role_id = (SELECT id FROM roles WHERE name = 'user') WHERE role = 'user';

-- Jadikan role_id NOT NULL setelah semua data terisi
ALTER TABLE users ALTER COLUMN role_id SET NOT NULL;

-- Tambahkan foreign key constraint
ALTER TABLE users ADD CONSTRAINT fk_user_role FOREIGN KEY (role_id) REFERENCES roles(id);

-- Hapus kolom 'role' yang lama
ALTER TABLE users DROP COLUMN role;

-- (Opsional tapi direkomendasikan) Seed beberapa izin dasar dan hubungkan ke peran default
INSERT INTO permissions (name, description) VALUES
    ('users:read:all', 'Read all user profiles'),
    ('users:update:status', 'Update user status (active, suspended)'),
    ('users:delete', 'Delete a user'),
    ('roles:manage', 'Manage roles and permissions'),
    ('permissions:manage', 'Manage permissions');

-- Berikan izin ini ke peran 'admin'
INSERT INTO role_permissions (role_id, permission_id)
SELECT
    (SELECT id FROM roles WHERE name = 'admin'),
    p.id
FROM permissions p WHERE p.name IN ('users:read:all', 'users:update:status', 'users:delete','roles:manage', 'permissions:manage');

-- Terapkan kembali trigger updated_at untuk tabel baru
CREATE TRIGGER set_timestamp_roles
BEFORE UPDATE ON roles
FOR EACH ROW
EXECUTE PROCEDURE trigger_set_timestamp();
