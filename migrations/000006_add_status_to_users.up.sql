CREATE TYPE user_status AS ENUM ('active', 'inactive', 'suspended');

ALTER TABLE users
ADD COLUMN status user_status NOT NULL DEFAULT 'active';

COMMENT ON COLUMN users.status IS 'The current status of the user account (active, inactive, suspended).';
