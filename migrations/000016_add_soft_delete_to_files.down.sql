-- File: infra/migrations/000016_add_soft_delete_to_files.down.sql

ALTER TABLE files DROP COLUMN deleted_at;
