USE mainthub_db;

CREATE TABLE IF NOT EXISTS users (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    full_name       VARCHAR(255)        NOT NULL,
    email           VARCHAR(255)        NOT NULL UNIQUE,
    password_hash   VARCHAR(255)        NOT NULL,
    role            ENUM('ADMIN', 'TECHNICIAN') NOT NULL DEFAULT 'TECHNICIAN',
    is_active       BOOLEAN             NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMP           NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP           NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX idx_users_email ON users(email);



CREATE TABLE IF NOT EXISTS machines (
    id                      INT AUTO_INCREMENT PRIMARY KEY,
    name                    VARCHAR(255)    NOT NULL,
    type                    VARCHAR(100)    NOT NULL,  
    location                VARCHAR(255),               
    maintenance_interval    INT             NOT NULL,   
    last_maintenance_date   DATE,                       
    next_maintenance_date   DATE            NOT NULL,   
    status                  ENUM('ACTIVE', 'INACTIVE', 'UNDER_MAINTENANCE') NOT NULL DEFAULT 'ACTIVE',
    created_by              INT             NOT NULL,
    created_at              TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at              TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_machine_created_by FOREIGN KEY (created_by) REFERENCES users(id)
);

CREATE INDEX idx_machines_status           ON machines(status);
CREATE INDEX idx_machines_next_date        ON machines(next_maintenance_date);
CREATE INDEX idx_machines_created_by       ON machines(created_by);



CREATE TABLE IF NOT EXISTS maintenance_history (
    id                  INT AUTO_INCREMENT PRIMARY KEY,
    machine_id          INT             NOT NULL,
    technician_id       INT             NOT NULL,
    maintenance_date    DATETIME        NOT NULL,
    status              ENUM('COMPLETED', 'SKIPPED', 'OVERDUE') NOT NULL DEFAULT 'COMPLETED',
    notes               TEXT,                           -- optional technician notes
    created_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_history_machine     FOREIGN KEY (machine_id)    REFERENCES machines(id) ON DELETE CASCADE,
    CONSTRAINT fk_history_technician  FOREIGN KEY (technician_id) REFERENCES users(id)
);

CREATE INDEX idx_history_machine_id    ON maintenance_history(machine_id);
CREATE INDEX idx_history_technician_id ON maintenance_history(technician_id);
CREATE INDEX idx_history_date          ON maintenance_history(maintenance_date);
CREATE INDEX idx_history_status        ON maintenance_history(status);



CREATE TABLE IF NOT EXISTS notifications (
    id                  INT AUTO_INCREMENT PRIMARY KEY,
    machine_id          INT             NOT NULL,
    user_id             INT             NOT NULL,       -- who gets the notification
    title               VARCHAR(255)    NOT NULL,
    message             TEXT            NOT NULL,
    notification_type   ENUM('REMINDER', 'OVERDUE', 'COMPLETED') NOT NULL DEFAULT 'REMINDER',
    is_sent             BOOLEAN         NOT NULL DEFAULT FALSE,
    is_read             BOOLEAN         NOT NULL DEFAULT FALSE,
    sent_at             DATETIME,
    created_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_notif_machine FOREIGN KEY (machine_id) REFERENCES machines(id) ON DELETE CASCADE,
    CONSTRAINT fk_notif_user    FOREIGN KEY (user_id)    REFERENCES users(id)    ON DELETE CASCADE
);

CREATE INDEX idx_notif_machine_id  ON notifications(machine_id);
CREATE INDEX idx_notif_user_id     ON notifications(user_id);
CREATE INDEX idx_notif_is_sent     ON notifications(is_sent);
CREATE INDEX idx_notif_is_read     ON notifications(is_read);



INSERT INTO users (full_name, email, password_hash, role)
VALUES (
    'Admin User',
    'admin@mainthub.com',
    '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj4oUBGGCNS.',  -- bcrypt of 'admin123'
    'ADMIN'
);


SELECT 'Database initialized successfully!' AS status;
SHOW TABLES;