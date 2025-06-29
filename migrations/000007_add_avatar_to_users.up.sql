ALTER TABLE users
ADD COLUMN avatar_url TEXT;

COMMENT ON COLUMN users.avatar_url IS 'URL or path to the user''s avatar image, served by the file-service.';
