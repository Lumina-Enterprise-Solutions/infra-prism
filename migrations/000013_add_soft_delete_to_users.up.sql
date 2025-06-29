-- File: infra/migrations/000013_add_soft_delete_to_users.up.sql
ALTER TABLE users ADD COLUMN deleted_at TIMESTAMPTZ;

CREATE INDEX idx_users_deleted_at ON users(deleted_at);

COMMENT ON COLUMN users.deleted_at IS 'Timestamp when the user was soft-deleted. NULL means the user is active.';
