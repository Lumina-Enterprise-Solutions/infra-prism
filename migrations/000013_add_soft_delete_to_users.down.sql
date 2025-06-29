-- File: infra/migrations/000013_add_soft_delete_to_users.down.sql
ALTER TABLE users DROP COLUMN deleted_at;
