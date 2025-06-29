CREATE TABLE refresh_tokens (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash VARCHAR(255) UNIQUE NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL
);

CREATE INDEX idx_refresh_tokens_user_id ON refresh_tokens(user_id);

COMMENT ON TABLE refresh_tokens IS 'Stores refresh tokens for users to extend their sessions.';
COMMENT ON COLUMN refresh_tokens.user_id IS 'The user this token belongs to.';
COMMENT ON COLUMN refresh_tokens.token_hash IS 'A cryptographic hash of the refresh token.';
COMMENT ON COLUMN refresh_tokens.expires_at IS 'The timestamp when this token expires.';
