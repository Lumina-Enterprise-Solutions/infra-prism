ALTER TABLE users
ADD COLUMN is_2fa_enabled BOOLEAN NOT NULL DEFAULT FALSE,
ADD COLUMN totp_secret VARCHAR(255) NOT NULL DEFAULT '';

COMMENT ON COLUMN users.is_2fa_enabled IS 'Flag to indicate if Two-Factor Authentication is enabled for the user.';
COMMENT ON COLUMN users.totp_secret IS 'The encrypted secret key for TOTP generation.';
