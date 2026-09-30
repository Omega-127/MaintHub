-- ============================================================
-- Migration: Add department columns to existing databases
-- Run this if you already have a running database and don't
-- want to reset from init.sql scratch.
-- ============================================================

-- 1. Add department to users table (NULL = Admin sees all)
ALTER TABLE users
    ADD COLUMN IF NOT EXISTS department ENUM('BLOWROOM', 'COMBER') NULL DEFAULT NULL
    AFTER role;

-- 2. Add department to machines table (default existing to BLOWROOM)
ALTER TABLE machines
    ADD COLUMN IF NOT EXISTS department ENUM('BLOWROOM', 'COMBER') NOT NULL DEFAULT 'BLOWROOM'
    AFTER type;

-- 3. Add index for fast department-based queries
CREATE INDEX IF NOT EXISTS idx_machines_department ON machines(department);

-- 4. All existing machines (Blowroom + Carding) → BLOWROOM department
UPDATE machines SET department = 'BLOWROOM'
WHERE type IN ('Blowroom', 'Carding');

-- 5. Insert COMBER machines (idempotent — only inserts if not already present)
INSERT IGNORE INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES
-- Top Comb Change | 730 days / 600 tons
('Comber 1 - Top Comb Change', 'Comber', 'COMBER', 'Comber Section', 730, '2026-08-09', '2028-08-09', 'ACTIVE', 1),
('Comber 2 - Top Comb Change', 'Comber', 'COMBER', 'Comber Section', 730, '2026-08-08', '2028-08-08', 'ACTIVE', 1),
('Comber 3 - Top Comb Change', 'Comber', 'COMBER', 'Comber Section', 730, '2026-09-06', '2028-09-06', 'ACTIVE', 1),
('Comber 4 - Top Comb Change', 'Comber', 'COMBER', 'Comber Section', 730, '2026-09-06', '2028-09-06', 'ACTIVE', 1),
('Comber 5 - Top Comb Change', 'Comber', 'COMBER', 'Comber Section', 730, '2026-09-06', '2028-09-06', 'ACTIVE', 1),
-- Half Lap Brush Change | 1095 days / 1000 tons
('Comber 1 - Half Lap Brush Change', 'Comber', 'COMBER', 'Comber Section', 1095, '2024-09-01', '2027-09-01', 'ACTIVE', 1),
('Comber 2 - Half Lap Brush Change', 'Comber', 'COMBER', 'Comber Section', 1095, '2024-09-08', '2027-09-08', 'ACTIVE', 1),
('Comber 3 - Half Lap Brush Change', 'Comber', 'COMBER', 'Comber Section', 1095, '2024-08-29', '2027-08-29', 'ACTIVE', 1),
('Comber 4 - Half Lap Brush Change', 'Comber', 'COMBER', 'Comber Section', 1095, '2024-09-14', '2027-09-14', 'ACTIVE', 1),
('Comber 5 - Half Lap Brush Change', 'Comber', 'COMBER', 'Comber Section', 1095, '2024-09-16', '2027-09-16', 'ACTIVE', 1),
-- Half Lap (Unicomb) Change | 1826 days / 1500 tons — OVERDUE
('Comber 1 - Half Lap (Unicomb) Change', 'Comber', 'COMBER', 'Comber Section', 1826, '2013-03-15', '2018-03-15', 'ACTIVE', 1),
('Comber 2 - Half Lap (Unicomb) Change', 'Comber', 'COMBER', 'Comber Section', 1826, '2013-03-15', '2018-03-15', 'ACTIVE', 1),
('Comber 3 - Half Lap (Unicomb) Change', 'Comber', 'COMBER', 'Comber Section', 1826, '2013-03-15', '2018-03-15', 'ACTIVE', 1),
('Comber 4 - Half Lap (Unicomb) Change', 'Comber', 'COMBER', 'Comber Section', 1826, '2013-03-15', '2018-03-15', 'ACTIVE', 1),
-- Half Lap Brush Setting | 180 days / 6 months
('Comber 1 - Half Lap Brush Setting', 'Comber', 'COMBER', 'Comber Section', 180, '2026-06-20', '2026-12-17', 'ACTIVE', 1),
('Comber 2 - Half Lap Brush Setting', 'Comber', 'COMBER', 'Comber Section', 180, '2026-06-20', '2026-12-17', 'ACTIVE', 1),
('Comber 3 - Half Lap Brush Setting', 'Comber', 'COMBER', 'Comber Section', 180, '2026-06-20', '2026-12-17', 'ACTIVE', 1),
('Comber 4 - Half Lap Brush Setting', 'Comber', 'COMBER', 'Comber Section', 180, '2026-06-20', '2026-12-17', 'ACTIVE', 1),
('Comber 5 - Half Lap Brush Setting', 'Comber', 'COMBER', 'Comber Section', 180, '2026-06-20', '2026-12-17', 'ACTIVE', 1),
-- Basic Settings | 180 days / 6 months
('Comber 1 - Basic Settings', 'Comber', 'COMBER', 'Comber Section', 180, '2026-08-01', '2027-01-28', 'ACTIVE', 1),
('Comber 2 - Basic Settings', 'Comber', 'COMBER', 'Comber Section', 180, '2026-08-01', '2027-01-28', 'ACTIVE', 1),
('Comber 3 - Basic Settings', 'Comber', 'COMBER', 'Comber Section', 180, '2026-08-01', '2027-01-28', 'ACTIVE', 1),
('Comber 4 - Basic Settings', 'Comber', 'COMBER', 'Comber Section', 180, '2026-08-01', '2027-01-28', 'ACTIVE', 1),
('Comber 5 - Basic Settings', 'Comber', 'COMBER', 'Comber Section', 180, '2026-08-01', '2027-01-28', 'ACTIVE', 1),
-- Gear Box Oil Change | 213 days / ~7 months / 200 tons
('Comber 1-5 - Gear Box Oil Change', 'Comber', 'COMBER', 'Comber Section', 213, '2026-07-12', '2027-02-10', 'ACTIVE', 1),
-- Servo Motor Gear Box Oil Change | 122 days / 4 months — OVERDUE
('Comber 1-5 - Servo Motor Gear Box Oil Change', 'Comber', 'COMBER', 'Comber Section', 122, '2025-12-02', '2026-04-03', 'ACTIVE', 1),
-- Unicomb Petrol Wash | 122 days / 4 months
('Comber 1-5 - Unicomb Petrol Wash', 'Comber', 'COMBER', 'Comber Section', 122, '2026-08-01', '2026-12-01', 'ACTIVE', 1);

-- Verify
SELECT department, COUNT(*) as machine_count FROM machines GROUP BY department;
