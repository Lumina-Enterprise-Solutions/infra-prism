CREATE TABLE files (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    original_name TEXT NOT NULL,
    storage_path TEXT NOT NULL UNIQUE,
    mime_type VARCHAR(255) NOT NULL,
    size_bytes BIGINT NOT NULL,
    owner_user_id UUID, -- Bisa NULL jika diupload oleh sistem
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_files_owner_user_id ON files(owner_user_id);
