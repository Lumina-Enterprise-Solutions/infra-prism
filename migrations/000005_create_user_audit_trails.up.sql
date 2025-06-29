CREATE TABLE user_audit_trails (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    target_user_id UUID NOT NULL,
    actor_user_id UUID NOT NULL,
    action VARCHAR(50) NOT NULL, -- e.g., 'UPDATE_PROFILE', 'DELETE_USER', 'CHANGE_STATUS'
    changes JSONB, -- Stores the "before" and "after" state as JSON
    timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    ip_address VARCHAR(45),
    user_agent TEXT
);

CREATE INDEX idx_audit_target_user_id ON user_audit_trails(target_user_id);
CREATE INDEX idx_audit_actor_user_id ON user_audit_trails(actor_user_id);

COMMENT ON TABLE user_audit_trails IS 'Records all changes made to user accounts.';
COMMENT ON COLUMN user_audit_trails.target_user_id IS 'The user whose record was changed.';
COMMENT ON COLUMN user_audit_trails.actor_user_id IS 'The user who performed the change.';
COMMENT ON COLUMN user_audit_trails.action IS 'The type of action performed.';
COMMENT ON COLUMN user_audit_trails.changes IS 'JSON object detailing what was changed.';
