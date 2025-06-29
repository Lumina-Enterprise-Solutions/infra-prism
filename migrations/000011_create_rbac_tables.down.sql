-- Hapus trigger set_timestamp_roles dari tabel roles
DROP TRIGGER IF EXISTS set_timestamp_roles ON roles;

-- Hapus data dari tabel role_permissions
DELETE FROM role_permissions;

-- Hapus data dari tabel permissions
DELETE FROM permissions;

-- Hapus data dari tabel roles
DELETE FROM roles;

-- Kembalikan kolom 'role' ke tabel users
ALTER TABLE users ADD COLUMN role VARCHAR(100);

-- Isi kolom role berdasarkan role_id
UPDATE users SET role = 'admin' WHERE role_id = (SELECT id FROM roles WHERE name = 'admin');
UPDATE users SET role = 'user' WHERE role_id = (SELECT id FROM roles WHERE name = 'user');

-- Hapus constraint foreign key fk_user_role dari tabel users
ALTER TABLE users DROP CONSTRAINT fk_user_role;

-- Hapus kolom role_id dari tabel users
ALTER TABLE users DROP COLUMN role_id;

-- Hapus tabel role_permissions
DROP TABLE role_permissions;

-- Hapus tabel permissions
DROP TABLE permissions;

-- Hapus tabel roles
DROP TABLE roles;
