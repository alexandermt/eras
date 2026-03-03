-- ERAS Seed Data v1.0
-- Run after 001_create_schema.sql

-- Default admin user (password managed via LDAP; local record for FK integrity)
INSERT INTO users (username, display_name, email, department, is_admin)
VALUES ('admin', 'ERAS Administrator', 'admin@example.com', 'IT', TRUE)
ON DUPLICATE KEY UPDATE is_admin = TRUE;

-- Sample programme codes as representative workspaces seed (informational)
-- No workspace rows seeded by default — created by users at runtime.

-- Note: programme values used at workspace creation are drawn from the
-- PROGRAMME_LIST constant in Core\uConstants.pas and config.ini.
