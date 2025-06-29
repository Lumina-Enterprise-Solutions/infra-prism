CREATE TABLE api_keys (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    key_hash VARCHAR(255) NOT NULL UNIQUE,
    -- PERBAIKAN FINAL: Gunakan ukuran yang jauh lebih aman.
    prefix VARCHAR(32) NOT NULL UNIQUE, -- Cukup untuk format 'pk_xxxxxxxxxxxxxxxx'
    description TEXT,
    expires_at TIMESTAMPTZ,
    last_used_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    revoked_at TIMESTAMPTZ
);
CREATE INDEX idx_api_keys_user_id ON api_keys(user_id);
COMMENT ON TABLE api_keys IS 'Stores hashed API keys for machine-to-machine authentication.';
