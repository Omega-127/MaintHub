-- ============================================================
-- Migration: Add Card A1-A6 & B1-B6 Additional Schedules
-- Sourced from Carding_Machine_Maintenance_Schedule.xlsx
--
-- Applies:
--   1. Lickerin Wire (9 months / 274 days) - 12 cards
--   2. Flat Grinding (6.5 months / 198 days) - 12 cards
--   3. SFL Maintenance (8.5 months / 258 days) - 12 cards
--
-- Total: 36 machines added to BLOWROOM / Carding Section
-- ============================================================

INSERT IGNORE INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES

-- Carding: Lickerin Wire (Schedule: 9 months / 274 days)
('Card A1 - Lickerin Wire', 'Carding', 'BLOWROOM', 'Carding Section', 274, '2025-10-11', '2026-07-11', 'ACTIVE', 1),
('Card A2 - Lickerin Wire', 'Carding', 'BLOWROOM', 'Carding Section', 274, '2026-07-03', '2027-04-03', 'ACTIVE', 1),
('Card A3 - Lickerin Wire', 'Carding', 'BLOWROOM', 'Carding Section', 274, '2025-08-21', '2026-05-21', 'ACTIVE', 1),
('Card A4 - Lickerin Wire', 'Carding', 'BLOWROOM', 'Carding Section', 274, '2026-06-20', '2027-03-21', 'ACTIVE', 1),
('Card A5 - Lickerin Wire', 'Carding', 'BLOWROOM', 'Carding Section', 274, '2025-10-15', '2026-07-15', 'ACTIVE', 1),
('Card A6 - Lickerin Wire', 'Carding', 'BLOWROOM', 'Carding Section', 274, '2025-10-10', '2026-07-10', 'ACTIVE', 1),
('Card B1 - Lickerin Wire', 'Carding', 'BLOWROOM', 'Carding Section', 274, '2025-11-29', '2026-08-30', 'ACTIVE', 1),
('Card B2 - Lickerin Wire', 'Carding', 'BLOWROOM', 'Carding Section', 274, '2026-06-30', '2027-03-31', 'ACTIVE', 1),
('Card B3 - Lickerin Wire', 'Carding', 'BLOWROOM', 'Carding Section', 274, '2025-08-19', '2026-05-19', 'ACTIVE', 1),
('Card B4 - Lickerin Wire', 'Carding', 'BLOWROOM', 'Carding Section', 274, '2025-12-03', '2026-09-03', 'ACTIVE', 1),
('Card B5 - Lickerin Wire', 'Carding', 'BLOWROOM', 'Carding Section', 274, '2026-06-26', '2027-03-27', 'ACTIVE', 1),
('Card B6 - Lickerin Wire', 'Carding', 'BLOWROOM', 'Carding Section', 274, '2025-08-24', '2026-05-24', 'ACTIVE', 1),

-- Carding: Flat Grinding (Schedule: 6.5 months / 198 days)
('Card A1 - Flat Grinding', 'Carding', 'BLOWROOM', 'Carding Section', 198, '2026-07-25', '2027-02-08', 'ACTIVE', 1),
('Card A2 - Flat Grinding', 'Carding', 'BLOWROOM', 'Carding Section', 198, '2025-12-10', '2026-06-26', 'ACTIVE', 1),
('Card A3 - Flat Grinding', 'Carding', 'BLOWROOM', 'Carding Section', 198, '2026-07-25', '2027-02-08', 'ACTIVE', 1),
('Card A4 - Flat Grinding', 'Carding', 'BLOWROOM', 'Carding Section', 198, '2026-08-05', '2027-02-19', 'ACTIVE', 1),
('Card A5 - Flat Grinding', 'Carding', 'BLOWROOM', 'Carding Section', 198, '2026-08-05', '2027-02-19', 'ACTIVE', 1),
('Card A6 - Flat Grinding', 'Carding', 'BLOWROOM', 'Carding Section', 198, '2026-07-28', '2027-02-11', 'ACTIVE', 1),
('Card B1 - Flat Grinding', 'Carding', 'BLOWROOM', 'Carding Section', 198, '2026-07-31', '2027-02-14', 'ACTIVE', 1),
('Card B2 - Flat Grinding', 'Carding', 'BLOWROOM', 'Carding Section', 198, '2026-01-06', '2026-07-23', 'ACTIVE', 1),
('Card B3 - Flat Grinding', 'Carding', 'BLOWROOM', 'Carding Section', 198, '2026-04-28', '2026-11-12', 'ACTIVE', 1),
('Card B4 - Flat Grinding', 'Carding', 'BLOWROOM', 'Carding Section', 198, '2026-04-10', '2026-10-25', 'ACTIVE', 1),
('Card B5 - Flat Grinding', 'Carding', 'BLOWROOM', 'Carding Section', 198, '2026-04-28', '2026-11-12', 'ACTIVE', 1),
('Card B6 - Flat Grinding', 'Carding', 'BLOWROOM', 'Carding Section', 198, '2026-08-04', '2027-02-18', 'ACTIVE', 1),

-- Carding: SFL Maintenance (Schedule: 8.5 months / 258 days)
('Card A1 - SFL Maintenance', 'Carding', 'BLOWROOM', 'Carding Section', 258, '2026-09-20', '2027-06-05', 'ACTIVE', 1),
('Card A2 - SFL Maintenance', 'Carding', 'BLOWROOM', 'Carding Section', 258, '2026-07-21', '2027-04-05', 'ACTIVE', 1),
('Card A3 - SFL Maintenance', 'Carding', 'BLOWROOM', 'Carding Section', 258, '2026-09-19', '2027-06-04', 'ACTIVE', 1),
('Card A4 - SFL Maintenance', 'Carding', 'BLOWROOM', 'Carding Section', 258, '2026-07-14', '2027-03-29', 'ACTIVE', 1),
('Card A5 - SFL Maintenance', 'Carding', 'BLOWROOM', 'Carding Section', 258, '2025-08-22', '2026-05-22', 'ACTIVE', 1),
('Card A6 - SFL Maintenance', 'Carding', 'BLOWROOM', 'Carding Section', 258, '2026-10-04', '2027-06-19', 'ACTIVE', 1),
('Card B1 - SFL Maintenance', 'Carding', 'BLOWROOM', 'Carding Section', 258, '2025-10-04', '2026-07-04', 'ACTIVE', 1),
('Card B2 - SFL Maintenance', 'Carding', 'BLOWROOM', 'Carding Section', 258, '2026-09-12', '2027-05-28', 'ACTIVE', 1),
('Card B3 - SFL Maintenance', 'Carding', 'BLOWROOM', 'Carding Section', 258, '2026-09-18', '2027-06-03', 'ACTIVE', 1),
('Card B4 - SFL Maintenance', 'Carding', 'BLOWROOM', 'Carding Section', 258, '2026-06-16', '2027-03-01', 'ACTIVE', 1),
('Card B5 - SFL Maintenance', 'Carding', 'BLOWROOM', 'Carding Section', 258, '2026-06-13', '2027-02-26', 'ACTIVE', 1),
('Card B6 - SFL Maintenance', 'Carding', 'BLOWROOM', 'Carding Section', 258, '2026-10-07', '2027-06-22', 'ACTIVE', 1);