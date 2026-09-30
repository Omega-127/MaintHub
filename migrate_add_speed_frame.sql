-- ============================================================
-- Migration: Add SPEED_FRAME department to existing databases
-- Run this AFTER the existing schema is in place.
-- This is safe to run multiple times (uses INSERT IGNORE).
-- ============================================================

-- 1. Extend the department ENUM on users table to include SPEED_FRAME
ALTER TABLE users
    MODIFY COLUMN department ENUM('BLOWROOM', 'COMBER', 'RING_FRAME', 'SPEED_FRAME') NULL DEFAULT NULL;

-- 2. Extend the department ENUM on machines table to include SPEED_FRAME
ALTER TABLE machines
    MODIFY COLUMN department ENUM('BLOWROOM', 'COMBER', 'RING_FRAME', 'SPEED_FRAME') NOT NULL DEFAULT 'BLOWROOM';

-- 3. Insert SPEED FRAME machines (idempotent -- only inserts if name not already present)
INSERT IGNORE INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES
-- Top & Bottom Apron Replacement 547 days / 18 months
('SF 1 - Top & Bottom Apron Replacement',  'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 547, '2024-11-26', '2026-05-26', 'ACTIVE', 1),
('SF 2 - Top & Bottom Apron Replacement',  'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 547, '2024-11-21', '2026-05-26', 'ACTIVE', 1),
('SF 3 - Top & Bottom Apron Replacement',  'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 547, '2024-11-24', '2026-05-26', 'ACTIVE', 1),
('SF 4 - Top & Bottom Apron Replacement',  'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 547, '2024-11-30', '2026-05-26', 'ACTIVE', 1),
-- Apron Washing 180 days 6 months OVERDUE
('SF 1 - Apron Washing', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 180, '2025-08-01', '2026-01-28', 'ACTIVE', 1),
('SF 2 - Apron Washing', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 180, '2025-08-05', '2026-02-01', 'ACTIVE', 1),
('SF 3 - Apron Washing', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 180, '2025-08-16', '2026-02-12', 'ACTIVE', 1),
-- False Twister Replacement 547 days 18 months
('SF 1 - False Twister Replacement', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 547, '2025-07-18', '2027-01-14', 'ACTIVE', 1),
('SF 2 - False Twister Replacement', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 547, '2025-07-19', '2027-01-14', 'ACTIVE', 1),
('SF 3 - False Twister Replacement', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 547, '2024-08-07', '2026-02-03', 'ACTIVE', 1),
('SF 4 - False Twister Replacement', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 547, '2025-09-20', '2027-03-21', 'ACTIVE', 1),
-- Cone Drum Belt Replacement 547 days 18 months
('SF 1 - Cone Drum Belt Replacement', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 547, '2024-01-18', '2025-07-18', 'ACTIVE', 1),
('SF 2 - Cone Drum Belt Replacement', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 547, '2025-12-18', '2027-06-17', 'ACTIVE', 1),
('SF 3 - Cone Drum Belt Replacement', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 547, '2024-12-04', '2026-06-04', 'ACTIVE', 1),
('SF 4 - Cone Drum Belt Replacement', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 547, '2024-03-06', '2025-09-04', 'ACTIVE', 1),
-- Clearer Cloths Top 1095 days 3 years OVERDUE
('SF 1 - Clearer Cloths Top Replacement', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 1095, '2022-03-30', '2025-03-30', 'ACTIVE', 1),
-- Clearer Cloths Bottom 1095 days 3 years OVERDUE
('SF 1-4 - Clearer Cloths Bottom Replacement', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 1095, '2022-06-01', '2025-06-01', 'ACTIVE', 1),
-- Trub Level Check 91 days 3 months
('SF 1 - Trub Level Check', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 91, '2026-07-01', '2026-09-30', 'ACTIVE', 1),
('SF 2 - Trub Level Check', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 91, '2026-07-01', '2026-09-30', 'ACTIVE', 1),
('SF 3 - Trub Level Check', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 91, '2026-07-01', '2026-09-30', 'ACTIVE', 1),
('SF 4 - Trub Level Check', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 91, '2026-07-01', '2026-09-30', 'ACTIVE', 1),
-- Saddle Gauge & Height Gauge 180 days 6 months
('SF 1 - Saddle Gauge & Height Gauge', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 180, '2026-04-01', '2026-09-28', 'ACTIVE', 1),
('SF 2 - Saddle Gauge & Height Gauge', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 180, '2026-04-01', '2026-09-28', 'ACTIVE', 1),
('SF 3 - Saddle Gauge & Height Gauge', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 180, '2026-04-01', '2026-09-28', 'ACTIVE', 1),
('SF 4 - Saddle Gauge & Height Gauge', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 180, '2026-04-01', '2026-09-28', 'ACTIVE', 1),
-- Trub Lift Chains 730 days 2 years OVERDUE
('SF 1 - Trub Lift Chains', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 730, '2024-01-01', '2026-01-01', 'ACTIVE', 1),
('SF 2 - Trub Lift Chains', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 730, '2024-01-01', '2026-01-01', 'ACTIVE', 1),
('SF 3 - Trub Lift Chains', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 730, '2024-01-01', '2026-01-01', 'ACTIVE', 1),
('SF 4 - Trub Lift Chains', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 730, '2024-01-01', '2026-01-01', 'ACTIVE', 1),
-- Balancing Weight Chain 730 days 2 years OVERDUE
('SF 1-4 - Balancing Weight Chain', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 730, '2020-08-01', '2022-08-01', 'ACTIVE', 1),
-- Distance Clip Spacer Change 1460 days 4 years OVERDUE
('SF 1-4 - Distance Clip Spacer Change', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 1460, '2018-11-01', '2022-11-01', 'ACTIVE', 1),
-- Flyer Cleaning 30 days OVERDUE
('SF 1-4 - Flyer Cleaning', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 30, '2025-11-22', '2025-12-22', 'ACTIVE', 1),
-- Waste Duct Cleaning 30 days OVERDUE
('SF 1-4 - Waste Duct Cleaning', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 30, '2026-02-03', '2026-03-05', 'ACTIVE', 1),
-- Suction Tube Cleaning 15 days OVERDUE
('SF 1-4 - Suction Tube Cleaning', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 15, '2024-10-17', '2024-11-01', 'ACTIVE', 1),
-- Differential Gearbox Oil Change 122 days 4 months OVERDUE
('SF 1 - Differential Gearbox Oil Change', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 122, '2026-04-07', '2026-08-07', 'ACTIVE', 1),
('SF 2 - Differential Gearbox Oil Change', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 122, '2025-09-12', '2026-01-12', 'ACTIVE', 1),
('SF 3 - Differential Gearbox Oil Change', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 122, '2026-04-09', '2026-08-09', 'ACTIVE', 1),
('SF 4 - Differential Gearbox Oil Change', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 122, '2025-10-04', '2026-02-03', 'ACTIVE', 1),
-- Foot Step Spindle Oil & Collar Cleaning 180 days 6 months
('SF 1 - Foot Step Spindle Oil & Collar Cleaning', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 180, '2026-02-19', '2026-08-18', 'ACTIVE', 1),
('SF 2 - Foot Step Spindle Oil & Collar Cleaning', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 180, '2026-03-05', '2026-09-01', 'ACTIVE', 1),
('SF 3 - Foot Step Spindle Oil & Collar Cleaning', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 180, '2026-01-27', '2026-07-26', 'ACTIVE', 1),
('SF 4 - Foot Step Spindle Oil & Collar Cleaning', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 180, '2026-01-08', '2026-07-07', 'ACTIVE', 1),
-- Bottom Roller Greasing 60 days 2 months OVERDUE
('SF 1-4 - Bottom Roller Greasing', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 60, '2026-04-09', '2026-06-08', 'ACTIVE', 1),
-- Arbour Greasing 730 days 2 years OVERDUE
('SF 1 - Arbour Greasing', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 730, '2023-09-26', '2025-09-26', 'ACTIVE', 1),
('SF 2 - Arbour Greasing', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 730, '2023-10-04', '2025-10-04', 'ACTIVE', 1),
('SF 3 - Arbour Greasing', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 730, '2023-09-28', '2025-09-28', 'ACTIVE', 1),
('SF 4 - Arbour Greasing', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 730, '2023-10-06', '2025-10-06', 'ACTIVE', 1),
-- Creel Roller Greasing & Trub Lifter 91 days 3 months OVERDUE
('SF 1-4 - Creel Roller Greasing & Trub Lifter', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 91, '2025-07-15', '2025-10-14', 'ACTIVE', 1),
-- Cone Drum Cam Wire Rope Inspection 91 days 3 months
('SF 1-4 - Cone Drum Cam Wire Rope Inspection', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 91, '2026-07-01', '2026-09-30', 'ACTIVE', 1),
-- Cots Buffing 60 days 0.2 mm
('SF 1-4 - Cots Buffing (Drafting Rollers)', 'Speed Frame', 'SPEED_FRAME', 'Speed Frame Section', 60, '2026-08-01', '2026-09-30', 'ACTIVE', 1);

-- 4. Verify results
SELECT department, COUNT(*) AS machine_count FROM machines GROUP BY department;
