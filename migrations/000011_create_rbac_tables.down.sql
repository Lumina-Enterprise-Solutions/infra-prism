-- Hapus trigger set_timestamp_roles dari tabel roles
DROP TRIGGER IF EXISTS set_timestamp_roles ON roles;

-- Kembalikan kolom 'role' ke tabel users
ALTER TABLE users ADD COLUMN role VARCHAR(100);

-- Isi kolom role berdasarkan role_id SEBELUM menghapus tabel roles
UPDATE users u SET role = (SELECT r.name FROM roles r WHERE r.id = u.role_id);

-- Hapus constraint foreign key fk_user_role dari tabel users
ALTER TABLE users DROP CONSTRAINT IF EXISTS fk_user_role;

-- Hapus kolom role_id dari tabel users
ALTER TABLE users DROP COLUMN IF EXISTS role_id;

-- Hapus data dari tabel-tabel RBAC
-- Hapus dari tabel pivot terlebih dahulu karena adanya foreign key
DELETE FROM role_permissions;
DELETE FROM permissions;
DELETE FROM roles;

-- Hapus tabel-tabel RBAC
DROP TABLE IF EXISTS role_permissions;
DROP TABLE IF EXISTS permissions;
DROP TABLE IF EXISTS roles;
