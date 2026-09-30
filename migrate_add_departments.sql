-- ============================================================
-- Migration: Add department columns to existing databases
-- Run this if you already have a running database and don't
-- want to reset from init.sql scratch.
-- ============================================================

-- 1. Add department to users table (NULL = Admin sees all)
ALTER TABLE users
    ADD COLUMN IF NOT EXISTS department ENUM('BLOWROOM', 'COMBER', 'RING_FRAME') NULL DEFAULT NULL
    AFTER role;

-- 2. Add department to machines table (default existing to BLOWROOM)
ALTER TABLE machines
    ADD COLUMN IF NOT EXISTS department ENUM('BLOWROOM', 'COMBER', 'RING_FRAME') NOT NULL DEFAULT 'BLOWROOM'
    AFTER type;

-- 3. Add index for fast department-based queries
CREATE INDEX IF NOT EXISTS idx_machines_department ON machines(department);

-- 4. All existing machines (Blowroom + Carding) to BLOWROOM department
UPDATE machines SET department = 'BLOWROOM'
WHERE type IN ('Blowroom', 'Carding');

-- 5. Insert COMBER machines (idempotent -- only inserts if not already present)
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
-- Half Lap (Unicomb) Change | 1826 days / 1500 tons -- OVERDUE
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
-- Gear Box Oil Change | 213 days
('Comber 1-5 - Gear Box Oil Change', 'Comber', 'COMBER', 'Comber Section', 213, '2026-07-12', '2027-02-10', 'ACTIVE', 1),
-- Servo Motor Gear Box Oil Change | 122 days -- OVERDUE
('Comber 1-5 - Servo Motor Gear Box Oil Change', 'Comber', 'COMBER', 'Comber Section', 122, '2025-12-02', '2026-04-03', 'ACTIVE', 1),
-- Unicomb Petrol Wash | 122 days
('Comber 1-5 - Unicomb Petrol Wash', 'Comber', 'COMBER', 'Comber Section', 122, '2026-08-01', '2026-12-01', 'ACTIVE', 1);

-- ============================================================
-- SPEED FRAME department (added from Speed_Frame_Maintenance_Schedule.xlsx)
-- ============================================================

-- 6. Extend ENUMs to include SPEED_FRAME
ALTER TABLE users
    MODIFY COLUMN department ENUM('BLOWROOM', 'COMBER', 'RING_FRAME', 'SPEED_FRAME') NULL DEFAULT NULL;

ALTER TABLE machines
    MODIFY COLUMN department ENUM('BLOWROOM', 'COMBER', 'RING_FRAME', 'SPEED_FRAME') NOT NULL DEFAULT 'BLOWROOM';

-- 7. Insert SPEED FRAME machines (idempotent -- INSERT IGNORE skips duplicates)
INSERT IGNORE INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES
-- Top & Bottom Apron Replacement | 547 days / 18 months
('SF 1 - Top & Bottom Apron Replacement', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 547, '2024-11-26', '2026-05-26', 'ACTIVE', 1),
('SF 2 - Top & Bottom Apron Replacement', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 547, '2024-11-21', '2026-05-26', 'ACTIVE', 1),
('SF 3 - Top & Bottom Apron Replacement', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 547, '2024-11-24', '2026-05-26', 'ACTIVE', 1),
('SF 4 - Top & Bottom Apron Replacement', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 547, '2024-11-30', '2026-05-26', 'ACTIVE', 1),
-- Apron Washing | 180 days / 6 months -- OVERDUE
('SF 1 - Apron Washing', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 180, '2025-08-01', '2026-01-28', 'ACTIVE', 1),
('SF 2 - Apron Washing', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 180, '2025-08-05', '2026-02-01', 'ACTIVE', 1),
('SF 3 - Apron Washing', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 180, '2025-08-16', '2026-02-12', 'ACTIVE', 1),
-- False Twister Replacement | 547 days / 18 months
('SF 1 - False Twister Replacement', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 547, '2025-07-18', '2027-01-14', 'ACTIVE', 1),
('SF 2 - False Twister Replacement', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 547, '2025-07-19', '2027-01-14', 'ACTIVE', 1),
('SF 3 - False Twister Replacement', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 547, '2024-08-07', '2026-02-03', 'ACTIVE', 1),
('SF 4 - False Twister Replacement', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 547, '2025-09-20', '2027-03-21', 'ACTIVE', 1),
-- Cone Drum Belt Replacement | 547 days / 18 months
('SF 1 - Cone Drum Belt Replacement', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 547, '2024-01-18', '2025-07-18', 'ACTIVE', 1),
('SF 2 - Cone Drum Belt Replacement', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 547, '2025-12-18', '2027-06-17', 'ACTIVE', 1),
('SF 3 - Cone Drum Belt Replacement', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 547, '2024-12-04', '2026-06-04', 'ACTIVE', 1),
('SF 4 - Cone Drum Belt Replacement', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 547, '2024-03-06', '2025-09-04', 'ACTIVE', 1),
-- Clearer Cloths Top | 1095 days / 3 years -- OVERDUE
('SF 1 - Clearer Cloths Top Replacement', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 1095, '2022-03-30', '2025-03-30', 'ACTIVE', 1),
-- Clearer Cloths Bottom | 1095 days / 3 years -- OVERDUE
('SF 1-4 - Clearer Cloths Bottom Replacement', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 1095, '2022-06-01', '2025-06-01', 'ACTIVE', 1),
-- Trub Level Check | 91 days / 3 months
('SF 1 - Trub Level Check', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 91, '2026-07-01', '2026-09-30', 'ACTIVE', 1),
('SF 2 - Trub Level Check', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 91, '2026-07-01', '2026-09-30', 'ACTIVE', 1),
('SF 3 - Trub Level Check', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 91, '2026-07-01', '2026-09-30', 'ACTIVE', 1),
('SF 4 - Trub Level Check', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 91, '2026-07-01', '2026-09-30', 'ACTIVE', 1),
-- Saddle Gauge & Height Gauge | 180 days / 6 months
('SF 1 - Saddle Gauge & Height Gauge', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 180, '2026-04-01', '2026-09-28', 'ACTIVE', 1),
('SF 2 - Saddle Gauge & Height Gauge', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 180, '2026-04-01', '2026-09-28', 'ACTIVE', 1),
('SF 3 - Saddle Gauge & Height Gauge', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 180, '2026-04-01', '2026-09-28', 'ACTIVE', 1),
('SF 4 - Saddle Gauge & Height Gauge', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 180, '2026-04-01', '2026-09-28', 'ACTIVE', 1),
-- Trub Lift Chains | 730 days / 2 years -- OVERDUE
('SF 1 - Trub Lift Chains', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 730, '2024-01-01', '2026-01-01', 'ACTIVE', 1),
('SF 2 - Trub Lift Chains', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 730, '2024-01-01', '2026-01-01', 'ACTIVE', 1),
('SF 3 - Trub Lift Chains', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 730, '2024-01-01', '2026-01-01', 'ACTIVE', 1),
('SF 4 - Trub Lift Chains', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 730, '2024-01-01', '2026-01-01', 'ACTIVE', 1),
-- Balancing Weight Chain | 730 days / 2 years -- OVERDUE
('SF 1-4 - Balancing Weight Chain', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 730, '2020-08-01', '2022-08-01', 'ACTIVE', 1),
-- Distance Clip Spacer Change | 1460 days / 4 years -- OVERDUE
('SF 1-4 - Distance Clip Spacer Change', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 1460, '2018-11-01', '2022-11-01', 'ACTIVE', 1),
-- Flyer Cleaning | 30 days -- OVERDUE
('SF 1-4 - Flyer Cleaning', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 30, '2025-11-22', '2025-12-22', 'ACTIVE', 1),
-- Waste Duct Cleaning | 30 days -- OVERDUE
('SF 1-4 - Waste Duct Cleaning', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 30, '2026-02-03', '2026-03-05', 'ACTIVE', 1),
-- Suction Tube Cleaning | 15 days -- OVERDUE
('SF 1-4 - Suction Tube Cleaning', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 15, '2024-10-17', '2024-11-01', 'ACTIVE', 1),
-- Differential Gearbox Oil Change | 122 days / 4 months -- OVERDUE
('SF 1 - Differential Gearbox Oil Change', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 122, '2026-04-07', '2026-08-07', 'ACTIVE', 1),
('SF 2 - Differential Gearbox Oil Change', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 122, '2025-09-12', '2026-01-12', 'ACTIVE', 1),
('SF 3 - Differential Gearbox Oil Change', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 122, '2026-04-09', '2026-08-09', 'ACTIVE', 1),
('SF 4 - Differential Gearbox Oil Change', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 122, '2025-10-04', '2026-02-03', 'ACTIVE', 1),
-- Foot Step Spindle Oil & Collar Cleaning | 180 days / 6 months
('SF 1 - Foot Step Spindle Oil & Collar Cleaning', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 180, '2026-02-19', '2026-08-18', 'ACTIVE', 1),
('SF 2 - Foot Step Spindle Oil & Collar Cleaning', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 180, '2026-03-05', '2026-09-01', 'ACTIVE', 1),
('SF 3 - Foot Step Spindle Oil & Collar Cleaning', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 180, '2026-01-27', '2026-07-26', 'ACTIVE', 1),
('SF 4 - Foot Step Spindle Oil & Collar Cleaning', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 180, '2026-01-08', '2026-07-07', 'ACTIVE', 1),
-- Bottom Roller Greasing | 60 days / 2 months -- OVERDUE
('SF 1-4 - Bottom Roller Greasing', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 60, '2026-04-09', '2026-06-08', 'ACTIVE', 1),
-- Arbour Greasing | 730 days / 2 years -- OVERDUE
('SF 1 - Arbour Greasing', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 730, '2023-09-26', '2025-09-26', 'ACTIVE', 1),
('SF 2 - Arbour Greasing', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 730, '2023-10-04', '2025-10-04', 'ACTIVE', 1),
('SF 3 - Arbour Greasing', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 730, '2023-09-28', '2025-09-28', 'ACTIVE', 1),
('SF 4 - Arbour Greasing', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 730, '2023-10-06', '2025-10-06', 'ACTIVE', 1),
-- Creel Roller Greasing & Trub Lifter | 91 days / 3 months -- OVERDUE
('SF 1-4 - Creel Roller Greasing & Trub Lifter', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 91, '2025-07-15', '2025-10-14', 'ACTIVE', 1),
-- Cone Drum Cam Wire Rope Inspection | 91 days / 3 months
('SF 1-4 - Cone Drum Cam Wire Rope Inspection', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 91, '2026-07-01', '2026-09-30', 'ACTIVE', 1),
-- Cots Buffing | 60 days / 0.2 mm
('SF 1-4 - Cots Buffing (Drafting Rollers)', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 60, '2026-08-01', '2026-09-30', 'ACTIVE', 1);


-- ============================================================
-- WINDING department (added from Winding_Maintenance_Schedule.xlsx)
-- No dates in source file; last_maintenance_date = 2026-09-30 placeholder.
-- Update actual dates via the app once confirmed.
-- ============================================================

-- 8. Extend ENUMs to include WINDING
ALTER TABLE users
    MODIFY COLUMN department ENUM('BLOWROOM', 'COMBER', 'RING_FRAME', 'SPEED_FRAME', 'WINDING') NULL DEFAULT NULL;

ALTER TABLE machines
    MODIFY COLUMN department ENUM('BLOWROOM', 'COMBER', 'RING_FRAME', 'SPEED_FRAME', 'WINDING') NOT NULL DEFAULT 'BLOWROOM';

-- 9. Insert WINDING machines -- AC 1-5 (Schlafhorst Automatic Coners)
INSERT IGNORE INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES
-- Leaf Spring | 2 Years (730 days)
('AC 1 - Leaf Spring', 'Automatic Coner', 'WINDING', 'Winding Section', 730, '2026-09-30', '2028-09-28', 'ACTIVE', 1),
('AC 2 - Leaf Spring', 'Automatic Coner', 'WINDING', 'Winding Section', 730, '2026-09-30', '2028-09-28', 'ACTIVE', 1),
('AC 3 - Leaf Spring', 'Automatic Coner', 'WINDING', 'Winding Section', 730, '2026-09-30', '2028-09-28', 'ACTIVE', 1),
('AC 4 - Leaf Spring', 'Automatic Coner', 'WINDING', 'Winding Section', 730, '2026-09-30', '2028-09-28', 'ACTIVE', 1),
('AC 5 - Leaf Spring', 'Automatic Coner', 'WINDING', 'Winding Section', 730, '2026-09-30', '2028-09-28', 'ACTIVE', 1),
-- Break Lining | 4 Years (1460 days)
('AC 1 - Break Lining', 'Automatic Coner', 'WINDING', 'Winding Section', 1460, '2026-09-30', '2030-09-25', 'ACTIVE', 1),
('AC 2 - Break Lining', 'Automatic Coner', 'WINDING', 'Winding Section', 1460, '2026-09-30', '2030-09-25', 'ACTIVE', 1),
('AC 3 - Break Lining', 'Automatic Coner', 'WINDING', 'Winding Section', 1460, '2026-09-30', '2030-09-25', 'ACTIVE', 1),
('AC 4 - Break Lining', 'Automatic Coner', 'WINDING', 'Winding Section', 1460, '2026-09-30', '2030-09-25', 'ACTIVE', 1),
('AC 5 - Break Lining', 'Automatic Coner', 'WINDING', 'Winding Section', 1460, '2026-09-30', '2030-09-25', 'ACTIVE', 1),
-- Scissor | 4 Years (1460 days)
('AC 1 - Scissor', 'Automatic Coner', 'WINDING', 'Winding Section', 1460, '2026-09-30', '2030-09-25', 'ACTIVE', 1),
('AC 2 - Scissor', 'Automatic Coner', 'WINDING', 'Winding Section', 1460, '2026-09-30', '2030-09-25', 'ACTIVE', 1),
('AC 3 - Scissor', 'Automatic Coner', 'WINDING', 'Winding Section', 1460, '2026-09-30', '2030-09-25', 'ACTIVE', 1),
('AC 4 - Scissor', 'Automatic Coner', 'WINDING', 'Winding Section', 1460, '2026-09-30', '2030-09-25', 'ACTIVE', 1),
('AC 5 - Scissor', 'Automatic Coner', 'WINDING', 'Winding Section', 1460, '2026-09-30', '2030-09-25', 'ACTIVE', 1),
-- Splicer Cleaning & Settings | 6 Months (180 days)
('AC 1 - Splicer Cleaning & Settings', 'Automatic Coner', 'WINDING', 'Winding Section', 180, '2026-09-30', '2027-03-29', 'ACTIVE', 1),
('AC 2 - Splicer Cleaning & Settings', 'Automatic Coner', 'WINDING', 'Winding Section', 180, '2026-09-30', '2027-03-29', 'ACTIVE', 1),
('AC 3 - Splicer Cleaning & Settings', 'Automatic Coner', 'WINDING', 'Winding Section', 180, '2026-09-30', '2027-03-29', 'ACTIVE', 1),
('AC 4 - Splicer Cleaning & Settings', 'Automatic Coner', 'WINDING', 'Winding Section', 180, '2026-09-30', '2027-03-29', 'ACTIVE', 1),
('AC 5 - Splicer Cleaning & Settings', 'Automatic Coner', 'WINDING', 'Winding Section', 180, '2026-09-30', '2027-03-29', 'ACTIVE', 1),
-- Splicer O Ring | 4 Years (1460 days)
('AC 1 - Splicer O Ring', 'Automatic Coner', 'WINDING', 'Winding Section', 1460, '2026-09-30', '2030-09-25', 'ACTIVE', 1),
('AC 2 - Splicer O Ring', 'Automatic Coner', 'WINDING', 'Winding Section', 1460, '2026-09-30', '2030-09-25', 'ACTIVE', 1),
('AC 3 - Splicer O Ring', 'Automatic Coner', 'WINDING', 'Winding Section', 1460, '2026-09-30', '2030-09-25', 'ACTIVE', 1),
('AC 4 - Splicer O Ring', 'Automatic Coner', 'WINDING', 'Winding Section', 1460, '2026-09-30', '2030-09-25', 'ACTIVE', 1),
('AC 5 - Splicer O Ring', 'Automatic Coner', 'WINDING', 'Winding Section', 1460, '2026-09-30', '2030-09-25', 'ACTIVE', 1),
-- Scissor Settings | 6 Months (180 days)
('AC 1 - Scissor Settings', 'Automatic Coner', 'WINDING', 'Winding Section', 180, '2026-09-30', '2027-03-29', 'ACTIVE', 1),
('AC 2 - Scissor Settings', 'Automatic Coner', 'WINDING', 'Winding Section', 180, '2026-09-30', '2027-03-29', 'ACTIVE', 1),
('AC 3 - Scissor Settings', 'Automatic Coner', 'WINDING', 'Winding Section', 180, '2026-09-30', '2027-03-29', 'ACTIVE', 1),
('AC 4 - Scissor Settings', 'Automatic Coner', 'WINDING', 'Winding Section', 180, '2026-09-30', '2027-03-29', 'ACTIVE', 1),
('AC 5 - Scissor Settings', 'Automatic Coner', 'WINDING', 'Winding Section', 180, '2026-09-30', '2027-03-29', 'ACTIVE', 1),
-- Drum Shaft Bearing Change | 6 Months (180 days)
('AC 1 - Drum Shaft Bearing Change', 'Automatic Coner', 'WINDING', 'Winding Section', 180, '2026-09-30', '2027-03-29', 'ACTIVE', 1),
('AC 2 - Drum Shaft Bearing Change', 'Automatic Coner', 'WINDING', 'Winding Section', 180, '2026-09-30', '2027-03-29', 'ACTIVE', 1),
('AC 3 - Drum Shaft Bearing Change', 'Automatic Coner', 'WINDING', 'Winding Section', 180, '2026-09-30', '2027-03-29', 'ACTIVE', 1),
('AC 4 - Drum Shaft Bearing Change', 'Automatic Coner', 'WINDING', 'Winding Section', 180, '2026-09-30', '2027-03-29', 'ACTIVE', 1),
('AC 5 - Drum Shaft Bearing Change', 'Automatic Coner', 'WINDING', 'Winding Section', 180, '2026-09-30', '2027-03-29', 'ACTIVE', 1),
-- Tension Assembly Cleaning & Splicer Cleaning | 6 Months (180 days)
('AC 1 - Tension Assembly Cleaning & Splicer Cleaning', 'Automatic Coner', 'WINDING', 'Winding Section', 180, '2026-09-30', '2027-03-29', 'ACTIVE', 1),
('AC 2 - Tension Assembly Cleaning & Splicer Cleaning', 'Automatic Coner', 'WINDING', 'Winding Section', 180, '2026-09-30', '2027-03-29', 'ACTIVE', 1),
('AC 3 - Tension Assembly Cleaning & Splicer Cleaning', 'Automatic Coner', 'WINDING', 'Winding Section', 180, '2026-09-30', '2027-03-29', 'ACTIVE', 1),
('AC 4 - Tension Assembly Cleaning & Splicer Cleaning', 'Automatic Coner', 'WINDING', 'Winding Section', 180, '2026-09-30', '2027-03-29', 'ACTIVE', 1),
('AC 5 - Tension Assembly Cleaning & Splicer Cleaning', 'Automatic Coner', 'WINDING', 'Winding Section', 180, '2026-09-30', '2027-03-29', 'ACTIVE', 1),
-- Drum & Drum Shaft Greasing | 10 Months (300 days)
('AC 1 - Drum & Drum Shaft Greasing', 'Automatic Coner', 'WINDING', 'Winding Section', 300, '2026-09-30', '2027-07-26', 'ACTIVE', 1),
('AC 2 - Drum & Drum Shaft Greasing', 'Automatic Coner', 'WINDING', 'Winding Section', 300, '2026-09-30', '2027-07-26', 'ACTIVE', 1),
('AC 3 - Drum & Drum Shaft Greasing', 'Automatic Coner', 'WINDING', 'Winding Section', 300, '2026-09-30', '2027-07-26', 'ACTIVE', 1),
('AC 4 - Drum & Drum Shaft Greasing', 'Automatic Coner', 'WINDING', 'Winding Section', 300, '2026-09-30', '2027-07-26', 'ACTIVE', 1),
('AC 5 - Drum & Drum Shaft Greasing', 'Automatic Coner', 'WINDING', 'Winding Section', 300, '2026-09-30', '2027-07-26', 'ACTIVE', 1),
-- Magazine Bearing Greasing | 12 Months (365 days)
('AC 1 - Magazine Bearing Greasing', 'Automatic Coner', 'WINDING', 'Winding Section', 365, '2026-09-30', '2027-09-30', 'ACTIVE', 1),
('AC 2 - Magazine Bearing Greasing', 'Automatic Coner', 'WINDING', 'Winding Section', 365, '2026-09-30', '2027-09-30', 'ACTIVE', 1),
('AC 3 - Magazine Bearing Greasing', 'Automatic Coner', 'WINDING', 'Winding Section', 365, '2026-09-30', '2027-09-30', 'ACTIVE', 1),
('AC 4 - Magazine Bearing Greasing', 'Automatic Coner', 'WINDING', 'Winding Section', 365, '2026-09-30', '2027-09-30', 'ACTIVE', 1),
('AC 5 - Magazine Bearing Greasing', 'Automatic Coner', 'WINDING', 'Winding Section', 365, '2026-09-30', '2027-09-30', 'ACTIVE', 1),
-- LH & RH Adaptor Greasing | 10 Months (300 days)
('AC 1 - LH & RH Adaptor Greasing', 'Automatic Coner', 'WINDING', 'Winding Section', 300, '2026-09-30', '2027-07-26', 'ACTIVE', 1),
('AC 2 - LH & RH Adaptor Greasing', 'Automatic Coner', 'WINDING', 'Winding Section', 300, '2026-09-30', '2027-07-26', 'ACTIVE', 1),
('AC 3 - LH & RH Adaptor Greasing', 'Automatic Coner', 'WINDING', 'Winding Section', 300, '2026-09-30', '2027-07-26', 'ACTIVE', 1),
('AC 4 - LH & RH Adaptor Greasing', 'Automatic Coner', 'WINDING', 'Winding Section', 300, '2026-09-30', '2027-07-26', 'ACTIVE', 1),
('AC 5 - LH & RH Adaptor Greasing', 'Automatic Coner', 'WINDING', 'Winding Section', 300, '2026-09-30', '2027-07-26', 'ACTIVE', 1),
-- Suction Arm, Waxing Device & Yarn Trap Pipe Cleaning | 12 Months (365 days)
('AC 1 - Suction Arm, Waxing Device & Yarn Trap Pipe Cleaning', 'Automatic Coner', 'WINDING', 'Winding Section', 365, '2026-09-30', '2027-09-30', 'ACTIVE', 1),
('AC 2 - Suction Arm, Waxing Device & Yarn Trap Pipe Cleaning', 'Automatic Coner', 'WINDING', 'Winding Section', 365, '2026-09-30', '2027-09-30', 'ACTIVE', 1),
('AC 3 - Suction Arm, Waxing Device & Yarn Trap Pipe Cleaning', 'Automatic Coner', 'WINDING', 'Winding Section', 365, '2026-09-30', '2027-09-30', 'ACTIVE', 1),
('AC 4 - Suction Arm, Waxing Device & Yarn Trap Pipe Cleaning', 'Automatic Coner', 'WINDING', 'Winding Section', 365, '2026-09-30', '2027-09-30', 'ACTIVE', 1),
('AC 5 - Suction Arm, Waxing Device & Yarn Trap Pipe Cleaning', 'Automatic Coner', 'WINDING', 'Winding Section', 365, '2026-09-30', '2027-09-30', 'ACTIVE', 1),
-- Prism & Splicer Cutter Cleaning & Setting | 6 Months (180 days)
('AC 1 - Prism & Splicer Cutter Cleaning & Setting', 'Automatic Coner', 'WINDING', 'Winding Section', 180, '2026-09-30', '2027-03-29', 'ACTIVE', 1),
('AC 2 - Prism & Splicer Cutter Cleaning & Setting', 'Automatic Coner', 'WINDING', 'Winding Section', 180, '2026-09-30', '2027-03-29', 'ACTIVE', 1),
('AC 3 - Prism & Splicer Cutter Cleaning & Setting', 'Automatic Coner', 'WINDING', 'Winding Section', 180, '2026-09-30', '2027-03-29', 'ACTIVE', 1),
('AC 4 - Prism & Splicer Cutter Cleaning & Setting', 'Automatic Coner', 'WINDING', 'Winding Section', 180, '2026-09-30', '2027-03-29', 'ACTIVE', 1),
('AC 5 - Prism & Splicer Cutter Cleaning & Setting', 'Automatic Coner', 'WINDING', 'Winding Section', 180, '2026-09-30', '2027-03-29', 'ACTIVE', 1),
-- Paper Cone Adaptor Cleaning | 12 Months (365 days)
('AC 1 - Paper Cone Adaptor Cleaning', 'Automatic Coner', 'WINDING', 'Winding Section', 365, '2026-09-30', '2027-09-30', 'ACTIVE', 1),
('AC 2 - Paper Cone Adaptor Cleaning', 'Automatic Coner', 'WINDING', 'Winding Section', 365, '2026-09-30', '2027-09-30', 'ACTIVE', 1),
('AC 3 - Paper Cone Adaptor Cleaning', 'Automatic Coner', 'WINDING', 'Winding Section', 365, '2026-09-30', '2027-09-30', 'ACTIVE', 1),
('AC 4 - Paper Cone Adaptor Cleaning', 'Automatic Coner', 'WINDING', 'Winding Section', 365, '2026-09-30', '2027-09-30', 'ACTIVE', 1),
('AC 5 - Paper Cone Adaptor Cleaning', 'Automatic Coner', 'WINDING', 'Winding Section', 365, '2026-09-30', '2027-09-30', 'ACTIVE', 1),
-- Suction Arm Setting | 12 Months (365 days)
('AC 1 - Suction Arm Setting', 'Automatic Coner', 'WINDING', 'Winding Section', 365, '2026-09-30', '2027-09-30', 'ACTIVE', 1),
('AC 2 - Suction Arm Setting', 'Automatic Coner', 'WINDING', 'Winding Section', 365, '2026-09-30', '2027-09-30', 'ACTIVE', 1),
('AC 3 - Suction Arm Setting', 'Automatic Coner', 'WINDING', 'Winding Section', 365, '2026-09-30', '2027-09-30', 'ACTIVE', 1),
('AC 4 - Suction Arm Setting', 'Automatic Coner', 'WINDING', 'Winding Section', 365, '2026-09-30', '2027-09-30', 'ACTIVE', 1),
('AC 5 - Suction Arm Setting', 'Automatic Coner', 'WINDING', 'Winding Section', 365, '2026-09-30', '2027-09-30', 'ACTIVE', 1),
-- Returner Tube Cleaning with Brasso | 6 Months (180 days)
('AC 1 - Returner Tube Cleaning with Brasso', 'Automatic Coner', 'WINDING', 'Winding Section', 180, '2026-09-30', '2027-03-29', 'ACTIVE', 1),
('AC 2 - Returner Tube Cleaning with Brasso', 'Automatic Coner', 'WINDING', 'Winding Section', 180, '2026-09-30', '2027-03-29', 'ACTIVE', 1),
('AC 3 - Returner Tube Cleaning with Brasso', 'Automatic Coner', 'WINDING', 'Winding Section', 180, '2026-09-30', '2027-03-29', 'ACTIVE', 1),
('AC 4 - Returner Tube Cleaning with Brasso', 'Automatic Coner', 'WINDING', 'Winding Section', 180, '2026-09-30', '2027-03-29', 'ACTIVE', 1),
('AC 5 - Returner Tube Cleaning with Brasso', 'Automatic Coner', 'WINDING', 'Winding Section', 180, '2026-09-30', '2027-03-29', 'ACTIVE', 1),
-- Empty Bobbin Gear Box Cleaning | 3 Months (91 days)
('AC 1 - Empty Bobbin Gear Box Cleaning', 'Automatic Coner', 'WINDING', 'Winding Section', 91, '2026-09-30', '2026-12-30', 'ACTIVE', 1),
('AC 2 - Empty Bobbin Gear Box Cleaning', 'Automatic Coner', 'WINDING', 'Winding Section', 91, '2026-09-30', '2026-12-30', 'ACTIVE', 1),
('AC 3 - Empty Bobbin Gear Box Cleaning', 'Automatic Coner', 'WINDING', 'Winding Section', 91, '2026-09-30', '2026-12-30', 'ACTIVE', 1),
('AC 4 - Empty Bobbin Gear Box Cleaning', 'Automatic Coner', 'WINDING', 'Winding Section', 91, '2026-09-30', '2026-12-30', 'ACTIVE', 1),
('AC 5 - Empty Bobbin Gear Box Cleaning', 'Automatic Coner', 'WINDING', 'Winding Section', 91, '2026-09-30', '2026-12-30', 'ACTIVE', 1),
-- Splicer Full Cleaning | 3 Months (91 days)
('AC 1 - Splicer Full Cleaning', 'Automatic Coner', 'WINDING', 'Winding Section', 91, '2026-09-30', '2026-12-30', 'ACTIVE', 1),
('AC 2 - Splicer Full Cleaning', 'Automatic Coner', 'WINDING', 'Winding Section', 91, '2026-09-30', '2026-12-30', 'ACTIVE', 1),
('AC 3 - Splicer Full Cleaning', 'Automatic Coner', 'WINDING', 'Winding Section', 91, '2026-09-30', '2026-12-30', 'ACTIVE', 1),
('AC 4 - Splicer Full Cleaning', 'Automatic Coner', 'WINDING', 'Winding Section', 91, '2026-09-30', '2026-12-30', 'ACTIVE', 1),
('AC 5 - Splicer Full Cleaning', 'Automatic Coner', 'WINDING', 'Winding Section', 91, '2026-09-30', '2026-12-30', 'ACTIVE', 1),
-- Machine Full Cleaning | 20 Days
('AC 1 - Machine Full Cleaning', 'Automatic Coner', 'WINDING', 'Winding Section', 20, '2026-09-30', '2026-10-20', 'ACTIVE', 1),
('AC 2 - Machine Full Cleaning', 'Automatic Coner', 'WINDING', 'Winding Section', 20, '2026-09-30', '2026-10-20', 'ACTIVE', 1),
('AC 3 - Machine Full Cleaning', 'Automatic Coner', 'WINDING', 'Winding Section', 20, '2026-09-30', '2026-10-20', 'ACTIVE', 1),
('AC 4 - Machine Full Cleaning', 'Automatic Coner', 'WINDING', 'Winding Section', 20, '2026-09-30', '2026-10-20', 'ACTIVE', 1),
('AC 5 - Machine Full Cleaning', 'Automatic Coner', 'WINDING', 'Winding Section', 20, '2026-09-30', '2026-10-20', 'ACTIVE', 1),
-- Bobbin Peg & Magazine Cleaning | 6 Months (180 days)
('AC 1 - Bobbin Peg & Magazine Cleaning', 'Automatic Coner', 'WINDING', 'Winding Section', 180, '2026-09-30', '2027-03-29', 'ACTIVE', 1),
('AC 2 - Bobbin Peg & Magazine Cleaning', 'Automatic Coner', 'WINDING', 'Winding Section', 180, '2026-09-30', '2027-03-29', 'ACTIVE', 1),
('AC 3 - Bobbin Peg & Magazine Cleaning', 'Automatic Coner', 'WINDING', 'Winding Section', 180, '2026-09-30', '2027-03-29', 'ACTIVE', 1),
('AC 4 - Bobbin Peg & Magazine Cleaning', 'Automatic Coner', 'WINDING', 'Winding Section', 180, '2026-09-30', '2027-03-29', 'ACTIVE', 1),
('AC 5 - Bobbin Peg & Magazine Cleaning', 'Automatic Coner', 'WINDING', 'Winding Section', 180, '2026-09-30', '2027-03-29', 'ACTIVE', 1),
-- Silicon Oiling to Adaptor | 2 Months (60 days)
('AC 1 - Silicon Oiling to Adaptor', 'Automatic Coner', 'WINDING', 'Winding Section', 60, '2026-09-30', '2026-11-29', 'ACTIVE', 1),
('AC 2 - Silicon Oiling to Adaptor', 'Automatic Coner', 'WINDING', 'Winding Section', 60, '2026-09-30', '2026-11-29', 'ACTIVE', 1),
('AC 3 - Silicon Oiling to Adaptor', 'Automatic Coner', 'WINDING', 'Winding Section', 60, '2026-09-30', '2026-11-29', 'ACTIVE', 1),
('AC 4 - Silicon Oiling to Adaptor', 'Automatic Coner', 'WINDING', 'Winding Section', 60, '2026-09-30', '2026-11-29', 'ACTIVE', 1),
('AC 5 - Silicon Oiling to Adaptor', 'Automatic Coner', 'WINDING', 'Winding Section', 60, '2026-09-30', '2026-11-29', 'ACTIVE', 1);

-- Verify all departments
SELECT department, COUNT(*) as machine_count FROM machines GROUP BY department;
