-- File: infra/migrations/000012_create_password_reset_tokens.up.sql
CREATE TABLE password_reset_tokens (
    token_hash VARCHAR(255) PRIMARY KEY,
    user_id UUID NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_user
        FOREIGN KEY(user_id)
        REFERENCES users(id)
        ON DELETE CASCADE
);

CREATE INDEX idx_pwd_reset_user_id ON password_reset_tokens(user_id);

COMMENT ON TABLE password_reset_tokens IS 'Stores single-use, hashed tokens for password reset requests.';
COMMENT ON COLUMN password_reset_tokens.token_hash IS 'A cryptographic hash (SHA256) of the reset token sent to the user.';
