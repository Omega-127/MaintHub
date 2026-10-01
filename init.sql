USE mainthub_db;

CREATE TABLE IF NOT EXISTS users (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    full_name       VARCHAR(255)        NOT NULL,
    email           VARCHAR(255)        NOT NULL UNIQUE,
    password_hash   VARCHAR(255)        NOT NULL,
    role            ENUM('ADMIN', 'TECHNICIAN') NOT NULL DEFAULT 'TECHNICIAN',
    department      ENUM('BLOWROOM', 'COMBER', 'RING_FRAME', 'SPEED_FRAME', 'WINDING', 'BUFFING') NULL DEFAULT NULL,
    is_active       BOOLEAN             NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMP           NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP           NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX idx_users_email ON users(email);



CREATE TABLE IF NOT EXISTS machines (
    id                      INT AUTO_INCREMENT PRIMARY KEY,
    name                    VARCHAR(255)    NOT NULL,
    type                    VARCHAR(100)    NOT NULL,
    department              ENUM('BLOWROOM', 'COMBER', 'RING_FRAME', 'SPEED_FRAME', 'WINDING', 'BUFFING') NOT NULL DEFAULT 'BLOWROOM',
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

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Bale Plucking Rolls', 'Blowroom', 'BLOWROOM', 'Blowroom Section', 1826, '2023-08-02', '2028-08-02', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Bale Plucker Lifting Belt', 'Blowroom', 'BLOWROOM', 'Blowroom Section', 1826, '2021-05-25', '2026-05-25', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Bale Plucker Up & Down Cam Roll Bearing', 'Blowroom', 'BLOWROOM', 'Blowroom Section', 730, '2024-03-02', '2026-03-02', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Chute Feed Opener Roll Nitrate (A1-A4, B1-B4)', 'Blowroom', 'BLOWROOM', 'Blowroom Section', 730, '2023-09-06', '2025-09-06', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Unimix Beater Wire', 'Blowroom', 'BLOWROOM', 'Blowroom Section', 912, '2025-12-17', '2028-06-17', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Unimix Feed Roll Bearing', 'Blowroom', 'BLOWROOM', 'Blowroom Section', 1826, '2018-06-18', '2023-06-18', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Unimix Gear Index', 'Blowroom', 'BLOWROOM', 'Blowroom Section', 730, '2025-01-17', '2027-01-17', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Flexiclean Beater Wire', 'Blowroom', 'BLOWROOM', 'Blowroom Section', 912, '2024-03-16', '2026-03-16', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Flexiclean Feed Roll Bearing', 'Blowroom', 'BLOWROOM', 'Blowroom Section', 1826, '2018-06-18', '2023-06-18', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Flexiclean Fluted Roll (Rubber)', 'Blowroom', 'BLOWROOM', 'Blowroom Section', 730, '2024-03-02', '2026-03-02', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Condensor Cage Drum', 'Blowroom', 'BLOWROOM', 'Blowroom Section', 1826, '2019-05-02', '2024-05-02', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Primer i-Qube (CCS) LED/UV Tubes', 'Blowroom', 'BLOWROOM', 'Blowroom Section', 730, '2025-02-01', '2027-02-01', 'ACTIVE', 1);

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
-- COMBER Department Machines
-- ============================================================

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

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Comber 1 - Half Lap (Unicomb) Change', 'Comber', 'COMBER', 'Comber Section', 1826, '2013-03-15', '2018-03-15', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Comber 2 - Half Lap (Unicomb) Change', 'Comber', 'COMBER', 'Comber Section', 1826, '2013-03-15', '2018-03-15', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Comber 3 - Half Lap (Unicomb) Change', 'Comber', 'COMBER', 'Comber Section', 1826, '2013-03-15', '2018-03-15', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Comber 4 - Half Lap (Unicomb) Change', 'Comber', 'COMBER', 'Comber Section', 1826, '2013-03-15', '2018-03-15', 'ACTIVE', 1);

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

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Comber 1-5 - Gear Box Oil Change', 'Comber', 'COMBER', 'Comber Section', 213, '2026-07-12', '2027-02-10', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Comber 1-5 - Servo Motor Gear Box Oil Change', 'Comber', 'COMBER', 'Comber Section', 122, '2025-12-02', '2026-04-03', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Comber 1-5 - Unicomb Petrol Wash', 'Comber', 'COMBER', 'Comber Section', 122, '2026-08-01', '2026-12-01', 'ACTIVE', 1);

-- ============================================================
-- RING_FRAME Department Machines
-- ============================================================

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('RF 1 - Top & Bottom Apron Replacement', 'Ring Frame LR9 AX', 'RING_FRAME', 'Ring Frame Section', 180, '2026-01-28', '2026-07-27', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('RF 2 - Top & Bottom Apron Replacement', 'Ring Frame LR9 AX', 'RING_FRAME', 'Ring Frame Section', 180, '2026-01-29', '2026-07-28', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('RF 3 - Top & Bottom Apron Replacement', 'Ring Frame LR9 AX', 'RING_FRAME', 'Ring Frame Section', 180, '2026-01-10', '2026-07-09', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('RF 4 - Top & Bottom Apron Replacement', 'Ring Frame LR9 AX', 'RING_FRAME', 'Ring Frame Section', 180, '2026-01-31', '2026-07-30', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('RF 5 - Top & Bottom Apron Replacement', 'Ring Frame LR9 AX', 'RING_FRAME', 'Ring Frame Section', 180, '2026-02-02', '2026-08-01', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('RF 6 - Top & Bottom Apron Replacement', 'Ring Frame LR9 AX', 'RING_FRAME', 'Ring Frame Section', 180, '2025-05-22', '2026-01-26', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('RF 7 - Top & Bottom Apron Replacement', 'Ring Frame LR9 AX', 'RING_FRAME', 'Ring Frame Section', 180, '2025-11-20', '2026-05-19', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('RF 8 - Top & Bottom Apron Replacement', 'Ring Frame LR9 AX', 'RING_FRAME', 'Ring Frame Section', 180, '2026-03-20', '2026-09-16', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('RF 9 - Top & Bottom Apron Replacement', 'Ring Frame LR9 AX', 'RING_FRAME', 'Ring Frame Section', 180, '2026-04-06', '2026-10-03', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('RF 10 - Top & Bottom Apron Replacement', 'Ring Frame LR9 AX', 'RING_FRAME', 'Ring Frame Section', 180, '2025-12-09', '2026-06-07', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('RF 11 - Top & Bottom Apron Replacement', 'Ring Frame LR9 AX', 'RING_FRAME', 'Ring Frame Section', 180, '2025-12-01', '2026-05-30', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('RF 12 - Top & Bottom Apron Replacement', 'Ring Frame LR9 AX', 'RING_FRAME', 'Ring Frame Section', 180, '2026-03-28', '2026-09-24', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('RF 13 - Top & Bottom Apron Replacement', 'Ring Frame LR9 AX', 'RING_FRAME', 'Ring Frame Section', 180, '2026-04-01', '2026-09-28', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('RF 1-5 - Main Shaft Greasing', 'Ring Frame LR9 AX', 'RING_FRAME', 'Ring Frame Section', 91, '2026-08-18', '2026-11-18', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('RF 6-13 - Main Shaft Greasing', 'Ring Frame LR9 AX', 'RING_FRAME', 'Ring Frame Section', 91, '2026-08-26', '2026-11-26', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('RF 1-13 - Spindle Oil Lubrication', 'Ring Frame LR9 AX', 'RING_FRAME', 'Ring Frame Section', 273, '2026-01-16', '2026-10-16', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('RF 1-13 - Arm Load & Roller Setting', 'Ring Frame LR9 AX', 'RING_FRAME', 'Ring Frame Section', 180, '2026-08-31', '2027-02-27', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('RF 1 - Jockey Pulley Greasing', 'Ring Frame LR9 AX', 'RING_FRAME', 'Ring Frame Section', 180, '2026-09-14', '2027-03-14', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('RF 6-13 - Jockey Pulley Greasing', 'Ring Frame LR9 AX', 'RING_FRAME', 'Ring Frame Section', 180, '2026-09-13', '2027-03-13', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('RF 1-5 - Drafting Pressure Hose', 'Ring Frame LR9 AX', 'RING_FRAME', 'Ring Frame Section', 1826, '2024-08-05', '2029-08-05', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('RF 6-13 - Drafting Pressure Hose', 'Ring Frame LR9 AX', 'RING_FRAME', 'Ring Frame Section', 1826, '2023-05-05', '2028-05-05', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('RF 1-5 - LMW Cradle Overhauling', 'Ring Frame LR9 AX', 'RING_FRAME', 'Ring Frame Section', 1826, '2024-04-11', '2029-04-11', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('RF 12 - Main Shaft Speeder Hub Bearing', 'Ring Frame LR9 AX', 'RING_FRAME', 'Ring Frame Section', 547, '2026-03-20', '2027-09-20', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('RF 13 - Main Shaft Speeder Hub Bearing', 'Ring Frame LR9 AX', 'RING_FRAME', 'Ring Frame Section', 547, '2026-03-14', '2027-09-14', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('RF 14 (Suessen) - Top & Bottom Apron Replacement', 'Ring Frame Suessen', 'RING_FRAME', 'Ring Frame Section', 273, '2026-05-24', '2027-02-21', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('RF 15 (Suessen) - Top & Bottom Apron Replacement', 'Ring Frame Suessen', 'RING_FRAME', 'Ring Frame Section', 273, '2026-05-26', '2027-02-23', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('RF 16 (Suessen) - Top & Bottom Apron Replacement', 'Ring Frame Suessen', 'RING_FRAME', 'Ring Frame Section', 273, '2026-05-27', '2027-02-24', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('RF 14-16 (Suessen) - Spindle Oil Change', 'Ring Frame Suessen', 'RING_FRAME', 'Ring Frame Section', 304, '2025-12-16', '2026-10-16', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('RF 14 (Suessen) - Fibre Gear Change', 'Ring Frame Suessen', 'RING_FRAME', 'Ring Frame Section', 213, '2025-08-08', '2026-03-09', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('RF 16 (Suessen) - Fibre Gear Change', 'Ring Frame Suessen', 'RING_FRAME', 'Ring Frame Section', 213, '2025-07-29', '2026-02-28', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('RF 14-16 (Suessen) - Main Shaft Greasing', 'Ring Frame Suessen', 'RING_FRAME', 'Ring Frame Section', 91, '2026-07-15', '2026-10-15', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('RF 14-16 (Suessen) - Elite Shaft Greasing', 'Ring Frame Suessen', 'RING_FRAME', 'Ring Frame Section', 152, '2025-09-30', '2026-03-02', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('RF 14-16 (Suessen) - Tension Pulley Greasing', 'Ring Frame Suessen', 'RING_FRAME', 'Ring Frame Section', 180, '2026-08-04', '2027-02-01', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('RF 14-16 (Suessen) - Arm Load & Saddle Gauge', 'Ring Frame Suessen', 'RING_FRAME', 'Ring Frame Section', 273, '2025-09-30', '2026-07-01', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('RF 14-16 (Suessen) - Ring Replacement', 'Ring Frame Suessen', 'RING_FRAME', 'Ring Frame Section', 1826, '2017-04-29', '2022-04-29', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('RF 1-13 - Off-end & Headstock Gear Greasing', 'Ring Frame LR9 AX', 'RING_FRAME', 'Ring Frame Section', 91, '2026-08-11', '2026-11-11', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('RF 1-13 - AutoDoffer Pusher Gauge & Gripper', 'Ring Frame LR9 AX', 'RING_FRAME', 'Ring Frame Section', 91, '2026-09-01', '2026-12-01', 'ACTIVE', 1);

-- ============================================================
-- SPEED_FRAME Department Machines
-- ============================================================

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('SF 1 - Top & Bottom Apron Replacement', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 547, '2024-11-26', '2026-05-26', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('SF 2 - Top & Bottom Apron Replacement', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 547, '2024-11-21', '2026-05-26', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('SF 3 - Top & Bottom Apron Replacement', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 547, '2024-11-24', '2026-05-26', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('SF 4 - Top & Bottom Apron Replacement', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 547, '2024-11-30', '2026-05-26', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('SF 1 - Apron Washing', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 180, '2025-08-01', '2026-01-28', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('SF 2 - Apron Washing', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 180, '2025-08-05', '2026-02-01', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('SF 3 - Apron Washing', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 180, '2025-08-16', '2026-02-12', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('SF 1 - False Twister Replacement', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 547, '2025-07-18', '2027-01-14', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('SF 2 - False Twister Replacement', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 547, '2025-07-19', '2027-01-14', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('SF 3 - False Twister Replacement', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 547, '2024-08-07', '2026-02-03', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('SF 4 - False Twister Replacement', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 547, '2025-09-20', '2027-03-21', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('SF 1 - Cone Drum Belt Replacement', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 547, '2024-01-18', '2025-07-18', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('SF 2 - Cone Drum Belt Replacement', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 547, '2025-12-18', '2027-06-17', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('SF 3 - Cone Drum Belt Replacement', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 547, '2024-12-04', '2026-06-04', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('SF 4 - Cone Drum Belt Replacement', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 547, '2024-03-06', '2025-09-04', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('SF 1 - Clearer Cloths Top Replacement', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 1095, '2022-03-30', '2025-03-30', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('SF 1-4 - Clearer Cloths Bottom Replacement', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 1095, '2022-06-01', '2025-06-01', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('SF 1 - Trub Level Check', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 91, '2026-07-01', '2026-09-30', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('SF 2 - Trub Level Check', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 91, '2026-07-01', '2026-09-30', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('SF 3 - Trub Level Check', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 91, '2026-07-01', '2026-09-30', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('SF 4 - Trub Level Check', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 91, '2026-07-01', '2026-09-30', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('SF 1 - Saddle Gauge & Height Gauge', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 180, '2026-04-01', '2026-09-28', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('SF 2 - Saddle Gauge & Height Gauge', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 180, '2026-04-01', '2026-09-28', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('SF 3 - Saddle Gauge & Height Gauge', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 180, '2026-04-01', '2026-09-28', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('SF 4 - Saddle Gauge & Height Gauge', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 180, '2026-04-01', '2026-09-28', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('SF 1 - Trub Lift Chains', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 730, '2024-01-01', '2026-01-01', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('SF 2 - Trub Lift Chains', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 730, '2024-01-01', '2026-01-01', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('SF 3 - Trub Lift Chains', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 730, '2024-01-01', '2026-01-01', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('SF 4 - Trub Lift Chains', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 730, '2024-01-01', '2026-01-01', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('SF 1-4 - Balancing Weight Chain', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 730, '2020-08-01', '2022-08-01', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('SF 1-4 - Distance Clip Spacer Change', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 1460, '2018-11-01', '2022-11-01', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('SF 1-4 - Flyer Cleaning', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 30, '2025-11-22', '2025-12-22', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('SF 1-4 - Waste Duct Cleaning', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 30, '2026-02-03', '2026-03-05', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('SF 1-4 - Suction Tube Cleaning', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 15, '2024-10-17', '2024-11-01', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('SF 1 - Differential Gearbox Oil Change', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 122, '2026-04-07', '2026-08-07', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('SF 2 - Differential Gearbox Oil Change', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 122, '2025-09-12', '2026-01-12', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('SF 3 - Differential Gearbox Oil Change', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 122, '2026-04-09', '2026-08-09', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('SF 4 - Differential Gearbox Oil Change', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 122, '2025-10-04', '2026-02-03', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('SF 1 - Foot Step Spindle Oil & Collar Cleaning', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 180, '2026-02-19', '2026-08-18', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('SF 2 - Foot Step Spindle Oil & Collar Cleaning', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 180, '2026-03-05', '2026-09-01', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('SF 3 - Foot Step Spindle Oil & Collar Cleaning', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 180, '2026-01-27', '2026-07-26', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('SF 4 - Foot Step Spindle Oil & Collar Cleaning', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 180, '2026-01-08', '2026-07-07', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('SF 1-4 - Bottom Roller Greasing', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 60, '2026-04-09', '2026-06-08', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('SF 1 - Arbour Greasing', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 730, '2023-09-26', '2025-09-26', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('SF 2 - Arbour Greasing', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 730, '2023-10-04', '2025-10-04', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('SF 3 - Arbour Greasing', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 730, '2023-09-28', '2025-09-28', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('SF 4 - Arbour Greasing', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 730, '2023-10-06', '2025-10-06', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('SF 1-4 - Creel Roller Greasing & Trub Lifter', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 91, '2025-07-15', '2025-10-14', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('SF 1-4 - Cone Drum Cam Wire Rope Inspection', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 91, '2026-07-01', '2026-09-30', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('SF 1-4 - Cots Buffing (Drafting Rollers)', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 60, '2026-09-30', '2026-11-29', 'ACTIVE', 1);

-- ============================================================
-- WINDING Department Machines
-- ============================================================

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 1 - Leaf Spring', 'Automatic Coner', 'WINDING', 'Winding Section', 730, '2026-09-30', '2028-09-28', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 2 - Leaf Spring', 'Automatic Coner', 'WINDING', 'Winding Section', 730, '2026-09-30', '2028-09-28', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 3 - Leaf Spring', 'Automatic Coner', 'WINDING', 'Winding Section', 730, '2026-09-30', '2028-09-28', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 4 - Leaf Spring', 'Automatic Coner', 'WINDING', 'Winding Section', 730, '2026-09-30', '2028-09-28', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 5 - Leaf Spring', 'Automatic Coner', 'WINDING', 'Winding Section', 730, '2026-09-30', '2028-09-28', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 1 - Break Lining', 'Automatic Coner', 'WINDING', 'Winding Section', 1460, '2026-09-30', '2030-09-25', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 2 - Break Lining', 'Automatic Coner', 'WINDING', 'Winding Section', 1460, '2026-09-30', '2030-09-25', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 3 - Break Lining', 'Automatic Coner', 'WINDING', 'Winding Section', 1460, '2026-09-30', '2030-09-25', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 4 - Break Lining', 'Automatic Coner', 'WINDING', 'Winding Section', 1460, '2026-09-30', '2030-09-25', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 5 - Break Lining', 'Automatic Coner', 'WINDING', 'Winding Section', 1460, '2026-09-30', '2030-09-25', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 1 - Scissor', 'Automatic Coner', 'WINDING', 'Winding Section', 1460, '2026-09-30', '2030-09-25', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 2 - Scissor', 'Automatic Coner', 'WINDING', 'Winding Section', 1460, '2026-09-30', '2030-09-25', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 3 - Scissor', 'Automatic Coner', 'WINDING', 'Winding Section', 1460, '2026-09-30', '2030-09-25', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 4 - Scissor', 'Automatic Coner', 'WINDING', 'Winding Section', 1460, '2026-09-30', '2030-09-25', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 5 - Scissor', 'Automatic Coner', 'WINDING', 'Winding Section', 1460, '2026-09-30', '2030-09-25', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 1 - Splicer Cleaning & Settings', 'Automatic Coner', 'WINDING', 'Winding Section', 180, '2026-09-30', '2027-03-29', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 2 - Splicer Cleaning & Settings', 'Automatic Coner', 'WINDING', 'Winding Section', 180, '2026-09-30', '2027-03-29', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 3 - Splicer Cleaning & Settings', 'Automatic Coner', 'WINDING', 'Winding Section', 180, '2026-09-30', '2027-03-29', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 4 - Splicer Cleaning & Settings', 'Automatic Coner', 'WINDING', 'Winding Section', 180, '2026-09-30', '2027-03-29', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 5 - Splicer Cleaning & Settings', 'Automatic Coner', 'WINDING', 'Winding Section', 180, '2026-09-30', '2027-03-29', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 1 - Splicer O Ring', 'Automatic Coner', 'WINDING', 'Winding Section', 1460, '2026-09-30', '2030-09-25', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 2 - Splicer O Ring', 'Automatic Coner', 'WINDING', 'Winding Section', 1460, '2026-09-30', '2030-09-25', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 3 - Splicer O Ring', 'Automatic Coner', 'WINDING', 'Winding Section', 1460, '2026-09-30', '2030-09-25', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 4 - Splicer O Ring', 'Automatic Coner', 'WINDING', 'Winding Section', 1460, '2026-09-30', '2030-09-25', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 5 - Splicer O Ring', 'Automatic Coner', 'WINDING', 'Winding Section', 1460, '2026-09-30', '2030-09-25', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 1 - Scissor Settings', 'Automatic Coner', 'WINDING', 'Winding Section', 180, '2026-09-30', '2027-03-29', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 2 - Scissor Settings', 'Automatic Coner', 'WINDING', 'Winding Section', 180, '2026-09-30', '2027-03-29', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 3 - Scissor Settings', 'Automatic Coner', 'WINDING', 'Winding Section', 180, '2026-09-30', '2027-03-29', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 4 - Scissor Settings', 'Automatic Coner', 'WINDING', 'Winding Section', 180, '2026-09-30', '2027-03-29', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 5 - Scissor Settings', 'Automatic Coner', 'WINDING', 'Winding Section', 180, '2026-09-30', '2027-03-29', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 1 - Drum Shaft Bearing Change', 'Automatic Coner', 'WINDING', 'Winding Section', 180, '2026-09-30', '2027-03-29', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 2 - Drum Shaft Bearing Change', 'Automatic Coner', 'WINDING', 'Winding Section', 180, '2026-09-30', '2027-03-29', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 3 - Drum Shaft Bearing Change', 'Automatic Coner', 'WINDING', 'Winding Section', 180, '2026-09-30', '2027-03-29', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 4 - Drum Shaft Bearing Change', 'Automatic Coner', 'WINDING', 'Winding Section', 180, '2026-09-30', '2027-03-29', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 5 - Drum Shaft Bearing Change', 'Automatic Coner', 'WINDING', 'Winding Section', 180, '2026-09-30', '2027-03-29', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 1 - Tension Assembly Cleaning & Splicer Cleaning', 'Automatic Coner', 'WINDING', 'Winding Section', 180, '2026-09-30', '2027-03-29', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 2 - Tension Assembly Cleaning & Splicer Cleaning', 'Automatic Coner', 'WINDING', 'Winding Section', 180, '2026-09-30', '2027-03-29', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 3 - Tension Assembly Cleaning & Splicer Cleaning', 'Automatic Coner', 'WINDING', 'Winding Section', 180, '2026-09-30', '2027-03-29', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 4 - Tension Assembly Cleaning & Splicer Cleaning', 'Automatic Coner', 'WINDING', 'Winding Section', 180, '2026-09-30', '2027-03-29', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 5 - Tension Assembly Cleaning & Splicer Cleaning', 'Automatic Coner', 'WINDING', 'Winding Section', 180, '2026-09-30', '2027-03-29', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 1 - Drum & Drum Shaft Greasing', 'Automatic Coner', 'WINDING', 'Winding Section', 300, '2026-09-30', '2027-07-26', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 2 - Drum & Drum Shaft Greasing', 'Automatic Coner', 'WINDING', 'Winding Section', 300, '2026-09-30', '2027-07-26', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 3 - Drum & Drum Shaft Greasing', 'Automatic Coner', 'WINDING', 'Winding Section', 300, '2026-09-30', '2027-07-26', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 4 - Drum & Drum Shaft Greasing', 'Automatic Coner', 'WINDING', 'Winding Section', 300, '2026-09-30', '2027-07-26', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 5 - Drum & Drum Shaft Greasing', 'Automatic Coner', 'WINDING', 'Winding Section', 300, '2026-09-30', '2027-07-26', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 1 - Magazine Bearing Greasing', 'Automatic Coner', 'WINDING', 'Winding Section', 365, '2026-09-30', '2027-09-30', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 2 - Magazine Bearing Greasing', 'Automatic Coner', 'WINDING', 'Winding Section', 365, '2026-09-30', '2027-09-30', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 3 - Magazine Bearing Greasing', 'Automatic Coner', 'WINDING', 'Winding Section', 365, '2026-09-30', '2027-09-30', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 4 - Magazine Bearing Greasing', 'Automatic Coner', 'WINDING', 'Winding Section', 365, '2026-09-30', '2027-09-30', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 5 - Magazine Bearing Greasing', 'Automatic Coner', 'WINDING', 'Winding Section', 365, '2026-09-30', '2027-09-30', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 1 - LH & RH Adaptor Greasing', 'Automatic Coner', 'WINDING', 'Winding Section', 300, '2026-09-30', '2027-07-26', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 2 - LH & RH Adaptor Greasing', 'Automatic Coner', 'WINDING', 'Winding Section', 300, '2026-09-30', '2027-07-26', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 3 - LH & RH Adaptor Greasing', 'Automatic Coner', 'WINDING', 'Winding Section', 300, '2026-09-30', '2027-07-26', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 4 - LH & RH Adaptor Greasing', 'Automatic Coner', 'WINDING', 'Winding Section', 300, '2026-09-30', '2027-07-26', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 5 - LH & RH Adaptor Greasing', 'Automatic Coner', 'WINDING', 'Winding Section', 300, '2026-09-30', '2027-07-26', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 1 - Suction Arm, Waxing Device & Yarn Trap Pipe Cleaning', 'Automatic Coner', 'WINDING', 'Winding Section', 365, '2026-09-30', '2027-09-30', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 2 - Suction Arm, Waxing Device & Yarn Trap Pipe Cleaning', 'Automatic Coner', 'WINDING', 'Winding Section', 365, '2026-09-30', '2027-09-30', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 3 - Suction Arm, Waxing Device & Yarn Trap Pipe Cleaning', 'Automatic Coner', 'WINDING', 'Winding Section', 365, '2026-09-30', '2027-09-30', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 4 - Suction Arm, Waxing Device & Yarn Trap Pipe Cleaning', 'Automatic Coner', 'WINDING', 'Winding Section', 365, '2026-09-30', '2027-09-30', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 5 - Suction Arm, Waxing Device & Yarn Trap Pipe Cleaning', 'Automatic Coner', 'WINDING', 'Winding Section', 365, '2026-09-30', '2027-09-30', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 1 - Prism & Splicer Cutter Cleaning & Setting', 'Automatic Coner', 'WINDING', 'Winding Section', 180, '2026-09-30', '2027-03-29', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 2 - Prism & Splicer Cutter Cleaning & Setting', 'Automatic Coner', 'WINDING', 'Winding Section', 180, '2026-09-30', '2027-03-29', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 3 - Prism & Splicer Cutter Cleaning & Setting', 'Automatic Coner', 'WINDING', 'Winding Section', 180, '2026-09-30', '2027-03-29', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 4 - Prism & Splicer Cutter Cleaning & Setting', 'Automatic Coner', 'WINDING', 'Winding Section', 180, '2026-09-30', '2027-03-29', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 5 - Prism & Splicer Cutter Cleaning & Setting', 'Automatic Coner', 'WINDING', 'Winding Section', 180, '2026-09-30', '2027-03-29', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 1 - Paper Cone Adaptor Cleaning', 'Automatic Coner', 'WINDING', 'Winding Section', 365, '2026-09-30', '2027-09-30', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 2 - Paper Cone Adaptor Cleaning', 'Automatic Coner', 'WINDING', 'Winding Section', 365, '2026-09-30', '2027-09-30', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 3 - Paper Cone Adaptor Cleaning', 'Automatic Coner', 'WINDING', 'Winding Section', 365, '2026-09-30', '2027-09-30', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 4 - Paper Cone Adaptor Cleaning', 'Automatic Coner', 'WINDING', 'Winding Section', 365, '2026-09-30', '2027-09-30', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 5 - Paper Cone Adaptor Cleaning', 'Automatic Coner', 'WINDING', 'Winding Section', 365, '2026-09-30', '2027-09-30', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 1 - Suction Arm Setting', 'Automatic Coner', 'WINDING', 'Winding Section', 365, '2026-09-30', '2027-09-30', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 2 - Suction Arm Setting', 'Automatic Coner', 'WINDING', 'Winding Section', 365, '2026-09-30', '2027-09-30', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 3 - Suction Arm Setting', 'Automatic Coner', 'WINDING', 'Winding Section', 365, '2026-09-30', '2027-09-30', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 4 - Suction Arm Setting', 'Automatic Coner', 'WINDING', 'Winding Section', 365, '2026-09-30', '2027-09-30', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 5 - Suction Arm Setting', 'Automatic Coner', 'WINDING', 'Winding Section', 365, '2026-09-30', '2027-09-30', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 1 - Returner Tube Cleaning with Brasso', 'Automatic Coner', 'WINDING', 'Winding Section', 180, '2026-09-30', '2027-03-29', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 2 - Returner Tube Cleaning with Brasso', 'Automatic Coner', 'WINDING', 'Winding Section', 180, '2026-09-30', '2027-03-29', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 3 - Returner Tube Cleaning with Brasso', 'Automatic Coner', 'WINDING', 'Winding Section', 180, '2026-09-30', '2027-03-29', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 4 - Returner Tube Cleaning with Brasso', 'Automatic Coner', 'WINDING', 'Winding Section', 180, '2026-09-30', '2027-03-29', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 5 - Returner Tube Cleaning with Brasso', 'Automatic Coner', 'WINDING', 'Winding Section', 180, '2026-09-30', '2027-03-29', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 1 - Empty Bobbin Gear Box Cleaning', 'Automatic Coner', 'WINDING', 'Winding Section', 91, '2026-09-30', '2026-12-30', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 2 - Empty Bobbin Gear Box Cleaning', 'Automatic Coner', 'WINDING', 'Winding Section', 91, '2026-09-30', '2026-12-30', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 3 - Empty Bobbin Gear Box Cleaning', 'Automatic Coner', 'WINDING', 'Winding Section', 91, '2026-09-30', '2026-12-30', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 4 - Empty Bobbin Gear Box Cleaning', 'Automatic Coner', 'WINDING', 'Winding Section', 91, '2026-09-30', '2026-12-30', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 5 - Empty Bobbin Gear Box Cleaning', 'Automatic Coner', 'WINDING', 'Winding Section', 91, '2026-09-30', '2026-12-30', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 1 - Splicer Full Cleaning', 'Automatic Coner', 'WINDING', 'Winding Section', 91, '2026-09-30', '2026-12-30', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 2 - Splicer Full Cleaning', 'Automatic Coner', 'WINDING', 'Winding Section', 91, '2026-09-30', '2026-12-30', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 3 - Splicer Full Cleaning', 'Automatic Coner', 'WINDING', 'Winding Section', 91, '2026-09-30', '2026-12-30', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 4 - Splicer Full Cleaning', 'Automatic Coner', 'WINDING', 'Winding Section', 91, '2026-09-30', '2026-12-30', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 5 - Splicer Full Cleaning', 'Automatic Coner', 'WINDING', 'Winding Section', 91, '2026-09-30', '2026-12-30', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 1 - Machine Full Cleaning', 'Automatic Coner', 'WINDING', 'Winding Section', 20, '2026-09-30', '2026-10-20', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 2 - Machine Full Cleaning', 'Automatic Coner', 'WINDING', 'Winding Section', 20, '2026-09-30', '2026-10-20', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 3 - Machine Full Cleaning', 'Automatic Coner', 'WINDING', 'Winding Section', 20, '2026-09-30', '2026-10-20', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 4 - Machine Full Cleaning', 'Automatic Coner', 'WINDING', 'Winding Section', 20, '2026-09-30', '2026-10-20', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 5 - Machine Full Cleaning', 'Automatic Coner', 'WINDING', 'Winding Section', 20, '2026-09-30', '2026-10-20', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 1 - Bobbin Peg & Magazine Cleaning', 'Automatic Coner', 'WINDING', 'Winding Section', 180, '2026-09-30', '2027-03-29', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 2 - Bobbin Peg & Magazine Cleaning', 'Automatic Coner', 'WINDING', 'Winding Section', 180, '2026-09-30', '2027-03-29', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 3 - Bobbin Peg & Magazine Cleaning', 'Automatic Coner', 'WINDING', 'Winding Section', 180, '2026-09-30', '2027-03-29', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 4 - Bobbin Peg & Magazine Cleaning', 'Automatic Coner', 'WINDING', 'Winding Section', 180, '2026-09-30', '2027-03-29', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 5 - Bobbin Peg & Magazine Cleaning', 'Automatic Coner', 'WINDING', 'Winding Section', 180, '2026-09-30', '2027-03-29', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 1 - Silicon Oiling to Adaptor', 'Automatic Coner', 'WINDING', 'Winding Section', 60, '2026-09-30', '2026-11-29', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 2 - Silicon Oiling to Adaptor', 'Automatic Coner', 'WINDING', 'Winding Section', 60, '2026-09-30', '2026-11-29', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 3 - Silicon Oiling to Adaptor', 'Automatic Coner', 'WINDING', 'Winding Section', 60, '2026-09-30', '2026-11-29', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 4 - Silicon Oiling to Adaptor', 'Automatic Coner', 'WINDING', 'Winding Section', 60, '2026-09-30', '2026-11-29', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('AC 5 - Silicon Oiling to Adaptor', 'Automatic Coner', 'WINDING', 'Winding Section', 60, '2026-09-30', '2026-11-29', 'ACTIVE', 1);

-- ============================================================
-- BUFFING Department Machines
-- ============================================================

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Breaker D/F - Cots No. 1 (Buffing)', 'Buffing Cots', 'BUFFING', 'Buffing Section', 20, '2026-09-10', '2026-09-30', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Finisher D/F - Cots No. 1 (Buffing)', 'Buffing Cots', 'BUFFING', 'Buffing Section', 20, '2026-09-10', '2026-09-30', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Finisher D/F - Cots No. 2 (Buffing)', 'Buffing Cots', 'BUFFING', 'Buffing Section', 20, '2026-09-10', '2026-09-30', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Finisher D/F - Cots No. 3 (Buffing)', 'Buffing Cots', 'BUFFING', 'Buffing Section', 20, '2026-09-10', '2026-09-30', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('SF 1 - Cots Buffing', 'Buffing Cots', 'BUFFING', 'Buffing Section', 60, '2026-08-27', '2026-10-26', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('SF 2 - Cots Buffing', 'Buffing Cots', 'BUFFING', 'Buffing Section', 60, '2026-09-16', '2026-11-15', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('SF 3 - Cots Buffing', 'Buffing Cots', 'BUFFING', 'Buffing Section', 60, '2026-08-27', '2026-10-26', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('SF 4 - Cots Buffing', 'Buffing Cots', 'BUFFING', 'Buffing Section', 60, '2026-08-19', '2026-10-18', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Unilap - Cots No. 1 (Buffing)', 'Buffing Cots', 'BUFFING', 'Buffing Section', 30, '2026-09-12', '2026-10-12', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Comber 1 - Drawbox Cots Buffing', 'Buffing Cots', 'BUFFING', 'Buffing Section', 30, '2026-09-12', '2026-10-12', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Comber 2 - Drawbox Cots Buffing', 'Buffing Cots', 'BUFFING', 'Buffing Section', 30, '2026-09-12', '2026-10-12', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Comber 3 - Drawbox Cots Buffing', 'Buffing Cots', 'BUFFING', 'Buffing Section', 30, '2026-09-12', '2026-10-12', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Comber 4 - Drawbox Cots Buffing', 'Buffing Cots', 'BUFFING', 'Buffing Section', 30, '2026-09-12', '2026-10-12', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Comber 5 - Drawbox Cots Buffing', 'Buffing Cots', 'BUFFING', 'Buffing Section', 30, '2026-09-12', '2026-10-12', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Comber 1 - Detaching Cots Buffing', 'Buffing Cots', 'BUFFING', 'Buffing Section', 90, '2026-09-03', '2026-12-02', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Comber 2 - Detaching Cots Buffing', 'Buffing Cots', 'BUFFING', 'Buffing Section', 90, '2026-09-01', '2026-11-30', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Comber 3 - Detaching Cots Buffing', 'Buffing Cots', 'BUFFING', 'Buffing Section', 90, '2026-09-27', '2026-12-26', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Comber 1 - Web Guide Cots Buffing', 'Buffing Cots', 'BUFFING', 'Buffing Section', 120, '2026-01-29', '2026-05-29', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Comber 2 - Web Guide Cots Buffing', 'Buffing Cots', 'BUFFING', 'Buffing Section', 120, '2026-09-01', '2026-12-30', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('Comber 3 - Web Guide Cots Buffing', 'Buffing Cots', 'BUFFING', 'Buffing Section', 120, '2026-09-27', '2027-01-25', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('RF 1 - Compact Cots Buffing', 'Buffing Cots', 'BUFFING', 'Buffing Section', 30, '2026-08-05', '2026-09-04', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('RF 2 - Compact Cots Buffing', 'Buffing Cots', 'BUFFING', 'Buffing Section', 30, '2026-08-06', '2026-09-05', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('RF 3 - Compact Cots Buffing', 'Buffing Cots', 'BUFFING', 'Buffing Section', 30, '2026-08-07', '2026-09-06', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('RF 4 - Compact Cots Buffing', 'Buffing Cots', 'BUFFING', 'Buffing Section', 30, '2026-08-09', '2026-09-08', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('RF 5 - Compact Cots Buffing', 'Buffing Cots', 'BUFFING', 'Buffing Section', 30, '2026-08-08', '2026-09-07', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('RF 6 - Compact Cots Buffing', 'Buffing Cots', 'BUFFING', 'Buffing Section', 30, '2026-08-11', '2026-09-10', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('RF 7 - Compact Cots Buffing', 'Buffing Cots', 'BUFFING', 'Buffing Section', 30, '2026-08-12', '2026-09-11', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('RF 8 - Compact Cots Buffing', 'Buffing Cots', 'BUFFING', 'Buffing Section', 30, '2026-08-15', '2026-09-14', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('RF 9 - Compact Cots Buffing', 'Buffing Cots', 'BUFFING', 'Buffing Section', 30, '2026-08-16', '2026-09-15', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('RF 10 - Compact Cots Buffing', 'Buffing Cots', 'BUFFING', 'Buffing Section', 30, '2026-08-13', '2026-09-12', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('RF 11 - Compact Cots Buffing', 'Buffing Cots', 'BUFFING', 'Buffing Section', 30, '2026-08-14', '2026-09-13', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('RF 12 - Compact Cots Buffing', 'Buffing Cots', 'BUFFING', 'Buffing Section', 30, '2026-08-18', '2026-09-17', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('RF 13 - Compact Cots Buffing', 'Buffing Cots', 'BUFFING', 'Buffing Section', 30, '2026-08-19', '2026-09-18', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('RF 1 - Front & Back Cots Buffing', 'Buffing Cots', 'BUFFING', 'Buffing Section', 30, '2026-08-23', '2026-09-22', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('RF 2 - Front & Back Cots Buffing', 'Buffing Cots', 'BUFFING', 'Buffing Section', 30, '2026-08-25', '2026-09-24', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('RF 3 - Front & Back Cots Buffing', 'Buffing Cots', 'BUFFING', 'Buffing Section', 30, '2026-08-26', '2026-09-25', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('RF 4 - Front & Back Cots Buffing', 'Buffing Cots', 'BUFFING', 'Buffing Section', 30, '2026-08-27', '2026-09-26', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('RF 5 - Front & Back Cots Buffing', 'Buffing Cots', 'BUFFING', 'Buffing Section', 30, '2026-08-28', '2026-09-27', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('RF 6 - Front & Back Cots Buffing', 'Buffing Cots', 'BUFFING', 'Buffing Section', 30, '2026-08-30', '2026-09-29', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('RF 7 - Front & Back Cots Buffing', 'Buffing Cots', 'BUFFING', 'Buffing Section', 30, '2026-08-29', '2026-09-28', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('RF 8 - Front & Back Cots Buffing', 'Buffing Cots', 'BUFFING', 'Buffing Section', 30, '2026-09-01', '2026-10-01', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('RF 9 - Front & Back Cots Buffing', 'Buffing Cots', 'BUFFING', 'Buffing Section', 30, '2026-09-02', '2026-10-02', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('RF 10 - Front & Back Cots Buffing', 'Buffing Cots', 'BUFFING', 'Buffing Section', 30, '2026-09-03', '2026-10-03', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('RF 11 - Front & Back Cots Buffing', 'Buffing Cots', 'BUFFING', 'Buffing Section', 30, '2026-09-04', '2026-10-04', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('RF 12 - Front & Back Cots Buffing', 'Buffing Cots', 'BUFFING', 'Buffing Section', 30, '2026-09-05', '2026-10-05', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('RF 13 - Front & Back Cots Buffing', 'Buffing Cots', 'BUFFING', 'Buffing Section', 30, '2026-09-06', '2026-10-06', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('RF 14 - Suessen Compact & Front Cots Buffing', 'Buffing Cots', 'BUFFING', 'Buffing Section', 30, '2026-08-01', '2026-08-31', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('RF 15 - Suessen Compact & Front Cots Buffing', 'Buffing Cots', 'BUFFING', 'Buffing Section', 30, '2026-08-02', '2026-09-01', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('RF 16 - Suessen Compact & Front Cots Buffing', 'Buffing Cots', 'BUFFING', 'Buffing Section', 30, '2026-08-04', '2026-09-03', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('RF 14 - Suessen Back Cots Buffing', 'Buffing Cots', 'BUFFING', 'Buffing Section', 60, '2026-08-20', '2026-10-19', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('RF 15 - Suessen Back Cots Buffing', 'Buffing Cots', 'BUFFING', 'Buffing Section', 60, '2026-08-22', '2026-10-21', 'ACTIVE', 1);

INSERT INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES ('RF 16 - Suessen Back Cots Buffing', 'Buffing Cots', 'BUFFING', 'Buffing Section', 60, '2026-08-21', '2026-10-20', 'ACTIVE', 1);


SELECT 'Database initialized successfully!' AS status;
SHOW TABLES;
SELECT id, name, department, next_maintenance_date,
       CASE WHEN next_maintenance_date <= CURDATE() THEN 'DUE / OVERDUE' ELSE 'OK' END AS maintenance_status
FROM machines
ORDER BY department, next_maintenance_date ASC;
