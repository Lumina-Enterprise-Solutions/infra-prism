-- File: infra/migrations/000017_create_org_and_teams_tables.down.sql

ALTER TABLE users DROP COLUMN IF EXISTS organization_id;

DROP TABLE IF EXISTS user_team_roles;
DROP TABLE IF EXISTS user_teams;
DROP TABLE IF EXISTS teams;
DROP TABLE IF EXISTS organizations;
