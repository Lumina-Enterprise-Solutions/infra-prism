ALTER TABLE files ADD COLUMN deleted_at TIMESTAMPTZ;

CREATE INDEX idx_files_deleted_at ON files(deleted_at);

COMMENT ON COLUMN files.deleted_at IS 'Timestamp when the file was soft-deleted. NULL means the file is active.';
