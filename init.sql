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



-- ============================================================
-- Seed data
-- ============================================================

-- Default admin user (password: admin123)
INSERT INTO users (full_name, email, password_hash, role)
VALUES (
    'Admin User',
    'admin@mainthub.com',
    '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj4oUBGGCNS.',
    'ADMIN'
);

-- ============================================================
-- Blowroom Machines
-- (Data sourced from Blowroom_Carding_Maintenance_Schedule.xlsx)
-- ============================================================

-- 1. Bale Plucking Rolls  |  Interval: ~5 yrs (1826 days)
--    New: 02.08.2023  →  Due: 02.08.2028
INSERT INTO machines (name, type, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Bale Plucking Rolls', 'Blowroom', 'Blowroom Section', 1826, '2023-08-02', '2028-08-02', 'ACTIVE', 1);

-- 2. Bale Plucker Lifting Belt  |  Interval: ~5 yrs (1826 days)
--    New: 25.05.2021  →  Due: 25.05.2026
INSERT INTO machines (name, type, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Bale Plucker Lifting Belt', 'Blowroom', 'Blowroom Section', 1826, '2021-05-25', '2026-05-25', 'ACTIVE', 1);

-- 3. Bale Plucker Up & Down Cam Roll Bearing  |  Interval: ~2 yrs (730 days)
--    Changed: 02.03.2024  →  Due: 02.03.2026
INSERT INTO machines (name, type, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Bale Plucker Up & Down Cam Roll Bearing', 'Blowroom', 'Blowroom Section', 730, '2024-03-02', '2026-03-02', 'ACTIVE', 1);

-- 4. Chute Feed Opener Roll Nitrate (A1-A4, B1-B4)  |  Interval: ~2 yrs (730 days)
--    Changed: 06.09.2023  →  Due: 06.09.2025
INSERT INTO machines (name, type, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Chute Feed Opener Roll Nitrate (A1-A4, B1-B4)', 'Blowroom', 'Blowroom Section', 730, '2023-09-06', '2025-09-06', 'ACTIVE', 1);

-- 5. Unimix Beater Wire  |  Interval: ~2.5 yrs (912 days)
--    Changed: 17.12.2025  →  Due: 17.06.2028
INSERT INTO machines (name, type, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Unimix Beater Wire', 'Blowroom', 'Blowroom Section', 912, '2025-12-17', '2028-06-17', 'ACTIVE', 1);

-- 6. Unimix Feed Roll Bearing  |  Interval: ~5 yrs (1826 days)
--    Changed: 18.06.2018  →  Due: 18.06.2023 (OVERDUE)
INSERT INTO machines (name, type, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Unimix Feed Roll Bearing', 'Blowroom', 'Blowroom Section', 1826, '2018-06-18', '2023-06-18', 'ACTIVE', 1);

-- 7. Unimix Gear Index  |  Interval: ~2 yrs (730 days)
--    Changed: 17.01.2025  →  Due: 17.01.2027
INSERT INTO machines (name, type, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Unimix Gear Index', 'Blowroom', 'Blowroom Section', 730, '2025-01-17', '2027-01-17', 'ACTIVE', 1);

-- 8. Flexiclean Beater Wire  |  Interval: ~2.5 yrs (912 days)
--    Changed: 16.03.2024  →  Due: 16.03.2026
INSERT INTO machines (name, type, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Flexiclean Beater Wire', 'Blowroom', 'Blowroom Section', 912, '2024-03-16', '2026-03-16', 'ACTIVE', 1);

-- 9. Flexiclean Feed Roll Bearing  |  Interval: ~5 yrs (1826 days)
--    Changed: 18.06.2018  →  Due: 18.06.2023 (OVERDUE)
INSERT INTO machines (name, type, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Flexiclean Feed Roll Bearing', 'Blowroom', 'Blowroom Section', 1826, '2018-06-18', '2023-06-18', 'ACTIVE', 1);

-- 10. Flexiclean Fluted Roll (Rubber)  |  Interval: ~2 yrs (730 days)
--     Changed: 02.03.2024  →  Due: 02.03.2026
INSERT INTO machines (name, type, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Flexiclean Fluted Roll (Rubber)', 'Blowroom', 'Blowroom Section', 730, '2024-03-02', '2026-03-02', 'ACTIVE', 1);

-- 11. Condensor Cage Drum  |  Interval: ~5 yrs (1826 days)
--     Changed: 02.05.2019  →  Due: 02.05.2024 (OVERDUE)
INSERT INTO machines (name, type, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Condensor Cage Drum', 'Blowroom', 'Blowroom Section', 1826, '2019-05-02', '2024-05-02', 'ACTIVE', 1);

-- 12. Primer i-Qube (CCS) LED/UV Tubes  |  Interval: ~2 yrs (730 days)
--     Changed: 01.02.2025  →  Due: 01.02.2027
INSERT INTO machines (name, type, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Primer i-Qube (CCS) LED/UV Tubes', 'Blowroom', 'Blowroom Section', 730, '2025-02-01', '2027-02-01', 'ACTIVE', 1);

-- ============================================================
-- Carding Machines  (Flat, Flat Belt, SFD, Cylinder & Doffer Wire Overhauling)
-- Interval: ~26 months / 600 tons (791 days)
-- (Data sourced from Blowroom_Carding_Maintenance_Schedule.xlsx)
-- ============================================================

-- Card A1  |  Changed: 02.04.2027 (latest)  →  Due based on interval
--           Previous due was 02.02.2025, overhauled → next cycle due ~02.04.2027
INSERT INTO machines (name, type, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Card A1 - Flat/Cylinder/Doffer Wire', 'Carding', 'Carding Section', 791, '2025-02-02', '2027-04-02', 'ACTIVE', 1);

-- Card A2  |  Changed: 06.11.2026  →  Due: 06.01.2029
INSERT INTO machines (name, type, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Card A2 - Flat/Cylinder/Doffer Wire', 'Carding', 'Carding Section', 791, '2024-09-06', '2026-11-06', 'ACTIVE', 1);

-- Card A3  |  Changed: 07.05.2027  →  Due: 07.07.2029
INSERT INTO machines (name, type, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Card A3 - Flat/Cylinder/Doffer Wire', 'Carding', 'Carding Section', 791, '2025-03-07', '2027-05-07', 'ACTIVE', 1);

-- Card A4  |  Changed: 18.07.2026  →  Due: 18.09.2028
INSERT INTO machines (name, type, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Card A4 - Flat/Cylinder/Doffer Wire', 'Carding', 'Carding Section', 791, '2024-05-18', '2026-07-18', 'ACTIVE', 1);

-- Card A5  |  Changed: 16.06.2026  →  Due: 16.08.2028
INSERT INTO machines (name, type, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Card A5 - Flat/Cylinder/Doffer Wire', 'Carding', 'Carding Section', 791, '2024-04-16', '2026-06-16', 'ACTIVE', 1);

-- Card A6  |  Changed: 16.02.2027  →  Due: 16.04.2029
INSERT INTO machines (name, type, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Card A6 - Flat/Cylinder/Doffer Wire', 'Carding', 'Carding Section', 791, '2024-12-16', '2027-02-16', 'ACTIVE', 1);

-- Card B1  |  Changed: 19.08.2027  →  Due: 19.10.2029
INSERT INTO machines (name, type, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Card B1 - Flat/Cylinder/Doffer Wire', 'Carding', 'Carding Section', 791, '2025-06-19', '2027-08-19', 'ACTIVE', 1);

-- Card B2  |  Changed: 07.02.2027  →  Due: 07.04.2029
INSERT INTO machines (name, type, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Card B2 - Flat/Cylinder/Doffer Wire', 'Carding', 'Carding Section', 791, '2024-12-07', '2027-02-07', 'ACTIVE', 1);

-- Card B3  |  Changed: 26.11.2026  →  Due: 26.01.2029
INSERT INTO machines (name, type, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Card B3 - Flat/Cylinder/Doffer Wire', 'Carding', 'Carding Section', 791, '2024-09-26', '2026-11-26', 'ACTIVE', 1);

-- Card B4  |  Changed: 11.09.2027  →  Due: 11.11.2029
INSERT INTO machines (name, type, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Card B4 - Flat/Cylinder/Doffer Wire', 'Carding', 'Carding Section', 791, '2025-09-11', '2027-09-11', 'ACTIVE', 1);

-- Card B5  |  Changed: 22.10.2026  →  Due: 22.12.2028
INSERT INTO machines (name, type, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Card B5 - Flat/Cylinder/Doffer Wire', 'Carding', 'Carding Section', 791, '2025-08-22', '2026-10-22', 'ACTIVE', 1);

-- Card B6  |  Changed: 17.03.2027  →  Due: 17.05.2029
INSERT INTO machines (name, type, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Card B6 - Flat/Cylinder/Doffer Wire', 'Carding', 'Carding Section', 791, '2025-01-17', '2027-03-17', 'ACTIVE', 1);


SELECT 'Database initialized successfully!' AS status;
SHOW TABLES;
SELECT id, name, type, next_maintenance_date,
       CASE WHEN next_maintenance_date <= CURDATE() THEN 'DUE / OVERDUE' ELSE 'OK' END AS maintenance_status
FROM machines
ORDER BY next_maintenance_date ASC;