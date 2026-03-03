-- ERAS MariaDB Schema v1.0
-- Already executed on 2026-03-03

CREATE TABLE IF NOT EXISTS users (
    id            INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    username      VARCHAR(100)  NOT NULL UNIQUE,
    display_name  VARCHAR(200),
    email         VARCHAR(255),
    department    VARCHAR(100),
    is_admin      BOOLEAN       NOT NULL DEFAULT FALSE,
    last_login_at DATETIME,
    created_at    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS workspaces (
    id            INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name          VARCHAR(200)  NOT NULL,
    description   TEXT,
    owner_id      INT UNSIGNED  NOT NULL,
    cycle_year    YEAR          NOT NULL,
    programme     VARCHAR(100),
    is_deleted    BOOLEAN       NOT NULL DEFAULT FALSE,
    created_at    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (owner_id) REFERENCES users(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS workspace_members (
    workspace_id  INT UNSIGNED  NOT NULL,
    user_id       INT UNSIGNED  NOT NULL,
    role          ENUM('viewer','editor','owner') NOT NULL DEFAULT 'viewer',
    added_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (workspace_id, user_id),
    FOREIGN KEY (workspace_id) REFERENCES workspaces(id),
    FOREIGN KEY (user_id)      REFERENCES users(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS snapshots (
    id            INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    workspace_id  INT UNSIGNED  NOT NULL,
    label         VARCHAR(200)  NOT NULL,
    frozen        BOOLEAN       NOT NULL DEFAULT FALSE,
    frozen_at     DATETIME,
    created_by    INT UNSIGNED  NOT NULL,
    created_at    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (workspace_id) REFERENCES workspaces(id),
    FOREIGN KEY (created_by)   REFERENCES users(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS snapshot_applicants (
    id               BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    snapshot_id      INT UNSIGNED    NOT NULL,
    oracle_ref       VARCHAR(50)     NOT NULL,
    applicant_data   JSON            NOT NULL,
    captured_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_snap_app (snapshot_id, oracle_ref),
    FOREIGN KEY (snapshot_id) REFERENCES snapshots(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS rankings (
    id               BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    snapshot_id      INT UNSIGNED    NOT NULL,
    oracle_ref       VARCHAR(50)     NOT NULL,
    rank_position    SMALLINT UNSIGNED,
    score            DECIMAL(6,2),
    notes            TEXT,
    status           ENUM('pending','ranked','shortlisted','rejected') NOT NULL DEFAULT 'pending',
    last_updated_by  INT UNSIGNED    NOT NULL,
    updated_at       DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_ranking (snapshot_id, oracle_ref),
    FOREIGN KEY (snapshot_id)      REFERENCES snapshots(id),
    FOREIGN KEY (last_updated_by)  REFERENCES users(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS audit_logs (
    id            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id       INT UNSIGNED    NOT NULL,
    workspace_id  INT UNSIGNED,
    snapshot_id   INT UNSIGNED,
    action        VARCHAR(100)    NOT NULL,
    entity_type   VARCHAR(50),
    entity_id     VARCHAR(100),
    payload       JSON,
    ip_address    VARCHAR(45),
    occurred_at   DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    INDEX idx_audit_workspace (workspace_id),
    INDEX idx_audit_occurred  (occurred_at)
) ENGINE=InnoDB;
