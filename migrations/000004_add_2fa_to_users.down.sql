ALTER TABLE users
DROP COLUMN is_2fa_enabled,
DROP COLUMN totp_secret;
