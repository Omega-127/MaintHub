USE mainthub_db;

CREATE TABLE IF NOT EXISTS users (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    full_name       VARCHAR(255)        NOT NULL,
    email           VARCHAR(255)        NOT NULL UNIQUE,
    password_hash   VARCHAR(255)        NOT NULL,
    role            ENUM('ADMIN', 'TECHNICIAN') NOT NULL DEFAULT 'TECHNICIAN',
    department      ENUM('BLOWROOM', 'COMBER') NULL DEFAULT NULL,
    is_active       BOOLEAN             NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMP           NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP           NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX idx_users_email ON users(email);



CREATE TABLE IF NOT EXISTS machines (
    id                      INT AUTO_INCREMENT PRIMARY KEY,
    name                    VARCHAR(255)    NOT NULL,
    type                    VARCHAR(100)    NOT NULL,
    department              ENUM('BLOWROOM', 'COMBER') NOT NULL DEFAULT 'BLOWROOM',
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
CREATE INDEX idx_machines_department       ON machines(department);



CREATE TABLE IF NOT EXISTS maintenance_history (
    id                  INT AUTO_INCREMENT PRIMARY KEY,
    machine_id          INT             NOT NULL,
    technician_id       INT             NOT NULL,
    maintenance_date    DATETIME        NOT NULL,
    status              ENUM('COMPLETED', 'SKIPPED', 'OVERDUE') NOT NULL DEFAULT 'COMPLETED',
    notes               TEXT,
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
    user_id             INT             NOT NULL,
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
INSERT INTO users (full_name, email, password_hash, role, department)
VALUES (
    'Admin User',
    'admin@mainthub.com',
    '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj4oUBGGCNS.',
    'ADMIN',
    NULL
);

-- ============================================================
-- BLOWROOM Department Machines
-- ============================================================

-- 1. Bale Plucking Rolls  |  Interval: ~5 yrs (1826 days)
INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Bale Plucking Rolls', 'Blowroom', 'BLOWROOM', 'Blowroom Section', 1826, '2023-08-02', '2028-08-02', 'ACTIVE', 1);

-- 2. Bale Plucker Lifting Belt  |  Interval: ~5 yrs (1826 days)
INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Bale Plucker Lifting Belt', 'Blowroom', 'BLOWROOM', 'Blowroom Section', 1826, '2021-05-25', '2026-05-25', 'ACTIVE', 1);

-- 3. Bale Plucker Up & Down Cam Roll Bearing  |  Interval: ~2 yrs (730 days)
INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Bale Plucker Up & Down Cam Roll Bearing', 'Blowroom', 'BLOWROOM', 'Blowroom Section', 730, '2024-03-02', '2026-03-02', 'ACTIVE', 1);

-- 4. Chute Feed Opener Roll Nitrate (A1-A4, B1-B4)  |  Interval: ~2 yrs (730 days)
INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Chute Feed Opener Roll Nitrate (A1-A4, B1-B4)', 'Blowroom', 'BLOWROOM', 'Blowroom Section', 730, '2023-09-06', '2025-09-06', 'ACTIVE', 1);

-- 5. Unimix Beater Wire  |  Interval: ~2.5 yrs (912 days)
INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Unimix Beater Wire', 'Blowroom', 'BLOWROOM', 'Blowroom Section', 912, '2025-12-17', '2028-06-17', 'ACTIVE', 1);

-- 6. Unimix Feed Roll Bearing  |  Interval: ~5 yrs (1826 days) — OVERDUE
INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Unimix Feed Roll Bearing', 'Blowroom', 'BLOWROOM', 'Blowroom Section', 1826, '2018-06-18', '2023-06-18', 'ACTIVE', 1);

-- 7. Unimix Gear Index  |  Interval: ~2 yrs (730 days)
INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Unimix Gear Index', 'Blowroom', 'BLOWROOM', 'Blowroom Section', 730, '2025-01-17', '2027-01-17', 'ACTIVE', 1);

-- 8. Flexiclean Beater Wire  |  Interval: ~2.5 yrs (912 days)
INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Flexiclean Beater Wire', 'Blowroom', 'BLOWROOM', 'Blowroom Section', 912, '2024-03-16', '2026-03-16', 'ACTIVE', 1);

-- 9. Flexiclean Feed Roll Bearing  |  Interval: ~5 yrs (1826 days) — OVERDUE
INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Flexiclean Feed Roll Bearing', 'Blowroom', 'BLOWROOM', 'Blowroom Section', 1826, '2018-06-18', '2023-06-18', 'ACTIVE', 1);

-- 10. Flexiclean Fluted Roll (Rubber)  |  Interval: ~2 yrs (730 days)
INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Flexiclean Fluted Roll (Rubber)', 'Blowroom', 'BLOWROOM', 'Blowroom Section', 730, '2024-03-02', '2026-03-02', 'ACTIVE', 1);

-- 11. Condensor Cage Drum  |  Interval: ~5 yrs (1826 days) — OVERDUE
INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Condensor Cage Drum', 'Blowroom', 'BLOWROOM', 'Blowroom Section', 1826, '2019-05-02', '2024-05-02', 'ACTIVE', 1);

-- 12. Primer i-Qube (CCS) LED/UV Tubes  |  Interval: ~2 yrs (730 days)
INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Primer i-Qube (CCS) LED/UV Tubes', 'Blowroom', 'BLOWROOM', 'Blowroom Section', 730, '2025-02-01', '2027-02-01', 'ACTIVE', 1);

-- Carding Machines (under BLOWROOM department) — ~26 months / 600 tons (791 days)
INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Card A1 - Flat/Cylinder/Doffer Wire', 'Carding', 'BLOWROOM', 'Carding Section', 791, '2025-02-02', '2027-04-02', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Card A2 - Flat/Cylinder/Doffer Wire', 'Carding', 'BLOWROOM', 'Carding Section', 791, '2024-09-06', '2026-11-06', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Card A3 - Flat/Cylinder/Doffer Wire', 'Carding', 'BLOWROOM', 'Carding Section', 791, '2025-03-07', '2027-05-07', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Card A4 - Flat/Cylinder/Doffer Wire', 'Carding', 'BLOWROOM', 'Carding Section', 791, '2024-05-18', '2026-07-18', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Card A5 - Flat/Cylinder/Doffer Wire', 'Carding', 'BLOWROOM', 'Carding Section', 791, '2024-04-16', '2026-06-16', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Card A6 - Flat/Cylinder/Doffer Wire', 'Carding', 'BLOWROOM', 'Carding Section', 791, '2024-12-16', '2027-02-16', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Card B1 - Flat/Cylinder/Doffer Wire', 'Carding', 'BLOWROOM', 'Carding Section', 791, '2025-06-19', '2027-08-19', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Card B2 - Flat/Cylinder/Doffer Wire', 'Carding', 'BLOWROOM', 'Carding Section', 791, '2024-12-07', '2027-02-07', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Card B3 - Flat/Cylinder/Doffer Wire', 'Carding', 'BLOWROOM', 'Carding Section', 791, '2024-09-26', '2026-11-26', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Card B4 - Flat/Cylinder/Doffer Wire', 'Carding', 'BLOWROOM', 'Carding Section', 791, '2025-09-11', '2027-09-11', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Card B5 - Flat/Cylinder/Doffer Wire', 'Carding', 'BLOWROOM', 'Carding Section', 791, '2025-08-22', '2026-10-22', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Card B6 - Flat/Cylinder/Doffer Wire', 'Carding', 'BLOWROOM', 'Carding Section', 791, '2025-01-17', '2027-03-17', 'ACTIVE', 1);


-- ============================================================
-- COMBER Department Machines (Comber LK-64)
-- Source: comber_schedules.xlsx
-- NOTE: Nipper Pin Changed is excluded per user instructions.
-- ============================================================

-- Top Comb Change | Schedule: 600 tons (2 years = 730 days) | Per comber head
INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Comber 1 - Top Comb Change', 'Comber', 'COMBER', 'Comber Section', 730, '2026-08-09', '2028-08-09', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Comber 2 - Top Comb Change', 'Comber', 'COMBER', 'Comber Section', 730, '2026-08-08', '2028-08-08', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Comber 3 - Top Comb Change', 'Comber', 'COMBER', 'Comber Section', 730, '2026-09-06', '2028-09-06', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Comber 4 - Top Comb Change', 'Comber', 'COMBER', 'Comber Section', 730, '2026-09-06', '2028-09-06', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Comber 5 - Top Comb Change', 'Comber', 'COMBER', 'Comber Section', 730, '2026-09-06', '2028-09-06', 'ACTIVE', 1);

-- Half Lap Brush Change | Schedule: 1000 tons (3 years = 1095 days) | Per comber head
INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Comber 1 - Half Lap Brush Change', 'Comber', 'COMBER', 'Comber Section', 1095, '2024-09-01', '2027-09-01', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Comber 2 - Half Lap Brush Change', 'Comber', 'COMBER', 'Comber Section', 1095, '2024-09-08', '2027-09-08', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Comber 3 - Half Lap Brush Change', 'Comber', 'COMBER', 'Comber Section', 1095, '2024-08-29', '2027-08-29', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Comber 4 - Half Lap Brush Change', 'Comber', 'COMBER', 'Comber Section', 1095, '2024-09-14', '2027-09-14', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Comber 5 - Half Lap Brush Change', 'Comber', 'COMBER', 'Comber Section', 1095, '2024-09-16', '2027-09-16', 'ACTIVE', 1);

-- Half Lap (Unicomb) Change | Schedule: 1500 tons (5 years = 1826 days) — OVERDUE
INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Comber 1 - Half Lap (Unicomb) Change', 'Comber', 'COMBER', 'Comber Section', 1826, '2013-03-15', '2018-03-15', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Comber 2 - Half Lap (Unicomb) Change', 'Comber', 'COMBER', 'Comber Section', 1826, '2013-03-15', '2018-03-15', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Comber 3 - Half Lap (Unicomb) Change', 'Comber', 'COMBER', 'Comber Section', 1826, '2013-03-15', '2018-03-15', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Comber 4 - Half Lap (Unicomb) Change', 'Comber', 'COMBER', 'Comber Section', 1826, '2013-03-15', '2018-03-15', 'ACTIVE', 1);

-- Half Lap Brush Setting | Schedule: 6 months (180 days) | Per comber head
INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Comber 1 - Half Lap Brush Setting', 'Comber', 'COMBER', 'Comber Section', 180, '2026-06-20', '2026-12-17', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Comber 2 - Half Lap Brush Setting', 'Comber', 'COMBER', 'Comber Section', 180, '2026-06-20', '2026-12-17', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Comber 3 - Half Lap Brush Setting', 'Comber', 'COMBER', 'Comber Section', 180, '2026-06-20', '2026-12-17', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Comber 4 - Half Lap Brush Setting', 'Comber', 'COMBER', 'Comber Section', 180, '2026-06-20', '2026-12-17', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Comber 5 - Half Lap Brush Setting', 'Comber', 'COMBER', 'Comber Section', 180, '2026-06-20', '2026-12-17', 'ACTIVE', 1);

-- Basic Settings | Schedule: 6 months (180 days) | All combers
INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Comber 1 - Basic Settings', 'Comber', 'COMBER', 'Comber Section', 180, '2026-08-01', '2027-01-28', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Comber 2 - Basic Settings', 'Comber', 'COMBER', 'Comber Section', 180, '2026-08-01', '2027-01-28', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Comber 3 - Basic Settings', 'Comber', 'COMBER', 'Comber Section', 180, '2026-08-01', '2027-01-28', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Comber 4 - Basic Settings', 'Comber', 'COMBER', 'Comber Section', 180, '2026-08-01', '2027-01-28', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Comber 5 - Basic Settings', 'Comber', 'COMBER', 'Comber Section', 180, '2026-08-01', '2027-01-28', 'ACTIVE', 1);

-- Gear Box Oil Change | Kluber 150 | Schedule: ~7 months / 200 tons (213 days) | All combers 1-5
INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Comber 1-5 - Gear Box Oil Change', 'Comber', 'COMBER', 'Comber Section', 213, '2026-07-12', '2027-02-10', 'ACTIVE', 1);

-- Servo Motor Gear Box Oil Change | 68 no. / 800 ml | Schedule: 4 months (122 days) | All combers 1-5 — OVERDUE
INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Comber 1-5 - Servo Motor Gear Box Oil Change', 'Comber', 'COMBER', 'Comber Section', 122, '2025-12-02', '2026-04-03', 'ACTIVE', 1);

-- Unicomb Petrol Wash | Schedule: 4 months (122 days) | All combers 1-5
INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Comber 1-5 - Unicomb Petrol Wash', 'Comber', 'COMBER', 'Comber Section', 122, '2026-08-01', '2026-12-01', 'ACTIVE', 1);

-- NOTE: Nipper Pin Changed is intentionally excluded per user instructions.


SELECT 'Database initialized successfully!' AS status;
SHOW TABLES;
SELECT id, name, department, next_maintenance_date,
       CASE WHEN next_maintenance_date <= CURDATE() THEN 'DUE / OVERDUE' ELSE 'OK' END AS maintenance_status
FROM machines
ORDER BY department, next_maintenance_date ASC;