ALTER TABLE users
ADD COLUMN role VARCHAR(50) NOT NULL DEFAULT 'user';

COMMENT ON COLUMN users.role IS 'User role (e.g., user, admin)';
