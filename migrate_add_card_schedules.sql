-- ============================================================
-- Migration: Add Card A1-A6 & B1-B6 Maintenance Schedules
-- Sourced from maintenance_schedule_transcribed.xlsx
--
-- Applies:
--   1. Flat Brush Change (18 months / 548 days) - 12 cards
--   2. Coiler Oil Change (18 months / 548 days, 220 no.) - 12 cards
--   3. Take up Roller Brush Change (18 months / 548 days) - 12 cards
--   4. Flat Comb (CRC) (1 year / 365 days) - 12 cards
--
-- Total: 48 machines added to BLOWROOM / Carding Section
-- ============================================================

INSERT IGNORE INTO machines (name, type, department, location, maintenance_interval, last_maintenance_date, next_maintenance_date, status, created_by)
VALUES
-- 1. Carding: Flat Brush Change | 548 days / 18 months
('Card A1 - Flat Brush Change', 'Carding', 'BLOWROOM', 'Carding Section', 548, '2026-05-27', '2027-11-27', 'ACTIVE', 1),
('Card A2 - Flat Brush Change', 'Carding', 'BLOWROOM', 'Carding Section', 548, '2026-05-27', '2027-11-27', 'ACTIVE', 1),
('Card A3 - Flat Brush Change', 'Carding', 'BLOWROOM', 'Carding Section', 548, '2026-05-26', '2027-11-27', 'ACTIVE', 1),
('Card A4 - Flat Brush Change', 'Carding', 'BLOWROOM', 'Carding Section', 548, '2026-05-24', '2027-11-24', 'ACTIVE', 1),
('Card A5 - Flat Brush Change', 'Carding', 'BLOWROOM', 'Carding Section', 548, '2026-05-30', '2027-11-27', 'ACTIVE', 1),
('Card A6 - Flat Brush Change', 'Carding', 'BLOWROOM', 'Carding Section', 548, '2026-06-08', '2027-11-27', 'ACTIVE', 1),
('Card B1 - Flat Brush Change', 'Carding', 'BLOWROOM', 'Carding Section', 548, '2026-06-28', '2027-11-27', 'ACTIVE', 1),
('Card B2 - Flat Brush Change', 'Carding', 'BLOWROOM', 'Carding Section', 548, '2026-05-26', '2027-11-27', 'ACTIVE', 1),
('Card B3 - Flat Brush Change', 'Carding', 'BLOWROOM', 'Carding Section', 548, '2026-05-29', '2027-11-27', 'ACTIVE', 1),
('Card B4 - Flat Brush Change', 'Carding', 'BLOWROOM', 'Carding Section', 548, '2026-05-28', '2027-11-27', 'ACTIVE', 1),
('Card B5 - Flat Brush Change', 'Carding', 'BLOWROOM', 'Carding Section', 548, '2026-05-15', '2027-11-27', 'ACTIVE', 1),
('Card B6 - Flat Brush Change', 'Carding', 'BLOWROOM', 'Carding Section', 548, '2026-06-08', '2027-11-27', 'ACTIVE', 1),

-- 2. Carding: Coiler Oil Change (220 no.) | 548 days / 18 months
('Card A1 - Coiler Oil Change', 'Carding', 'BLOWROOM', 'Carding Section', 548, '2023-10-10', '2025-04-10', 'ACTIVE', 1),
('Card A2 - Coiler Oil Change', 'Carding', 'BLOWROOM', 'Carding Section', 548, '2025-09-26', '2027-03-26', 'ACTIVE', 1),
('Card A3 - Coiler Oil Change', 'Carding', 'BLOWROOM', 'Carding Section', 548, '2025-09-26', '2027-03-26', 'ACTIVE', 1),
('Card A4 - Coiler Oil Change', 'Carding', 'BLOWROOM', 'Carding Section', 548, '2025-09-26', '2027-03-26', 'ACTIVE', 1),
('Card A5 - Coiler Oil Change', 'Carding', 'BLOWROOM', 'Carding Section', 548, '2025-09-26', '2027-03-26', 'ACTIVE', 1),
('Card A6 - Coiler Oil Change', 'Carding', 'BLOWROOM', 'Carding Section', 548, '2025-09-26', '2027-03-26', 'ACTIVE', 1),
('Card B1 - Coiler Oil Change', 'Carding', 'BLOWROOM', 'Carding Section', 548, '2025-09-26', '2027-03-26', 'ACTIVE', 1),
('Card B2 - Coiler Oil Change', 'Carding', 'BLOWROOM', 'Carding Section', 548, '2025-09-26', '2027-03-26', 'ACTIVE', 1),
('Card B3 - Coiler Oil Change', 'Carding', 'BLOWROOM', 'Carding Section', 548, '2025-09-26', '2027-03-26', 'ACTIVE', 1),
('Card B4 - Coiler Oil Change', 'Carding', 'BLOWROOM', 'Carding Section', 548, '2025-09-26', '2027-03-26', 'ACTIVE', 1),
('Card B5 - Coiler Oil Change', 'Carding', 'BLOWROOM', 'Carding Section', 548, '2025-09-26', '2027-03-26', 'ACTIVE', 1),
('Card B6 - Coiler Oil Change', 'Carding', 'BLOWROOM', 'Carding Section', 548, '2025-09-26', '2027-03-26', 'ACTIVE', 1),

-- 3. Carding: Take up Roller Brush Change | 548 days / 18 months
('Card A1 - Take up Roller Brush Change', 'Carding', 'BLOWROOM', 'Carding Section', 548, '2024-10-01', '2026-04-01', 'ACTIVE', 1),
('Card A2 - Take up Roller Brush Change', 'Carding', 'BLOWROOM', 'Carding Section', 548, '2024-10-01', '2026-04-01', 'ACTIVE', 1),
('Card A3 - Take up Roller Brush Change', 'Carding', 'BLOWROOM', 'Carding Section', 548, '2024-10-01', '2026-04-01', 'ACTIVE', 1),
('Card A4 - Take up Roller Brush Change', 'Carding', 'BLOWROOM', 'Carding Section', 548, '2024-10-01', '2026-04-01', 'ACTIVE', 1),
('Card A5 - Take up Roller Brush Change', 'Carding', 'BLOWROOM', 'Carding Section', 548, '2024-10-01', '2026-04-01', 'ACTIVE', 1),
('Card A6 - Take up Roller Brush Change', 'Carding', 'BLOWROOM', 'Carding Section', 548, '2024-10-01', '2026-04-01', 'ACTIVE', 1),
('Card B1 - Take up Roller Brush Change', 'Carding', 'BLOWROOM', 'Carding Section', 548, '2024-10-01', '2026-04-01', 'ACTIVE', 1),
('Card B2 - Take up Roller Brush Change', 'Carding', 'BLOWROOM', 'Carding Section', 548, '2024-10-01', '2026-04-01', 'ACTIVE', 1),
('Card B3 - Take up Roller Brush Change', 'Carding', 'BLOWROOM', 'Carding Section', 548, '2025-08-19', '2027-02-19', 'ACTIVE', 1),
('Card B4 - Take up Roller Brush Change', 'Carding', 'BLOWROOM', 'Carding Section', 548, '2024-10-01', '2026-04-01', 'ACTIVE', 1),
('Card B5 - Take up Roller Brush Change', 'Carding', 'BLOWROOM', 'Carding Section', 548, '2024-10-01', '2026-04-01', 'ACTIVE', 1),
('Card B6 - Take up Roller Brush Change', 'Carding', 'BLOWROOM', 'Carding Section', 548, '2024-10-01', '2026-04-01', 'ACTIVE', 1),

-- 4. Carding: Flat Comb (CRC) | 365 days / 1 year
('Card A1 - Flat Comb', 'Carding', 'BLOWROOM', 'Carding Section', 365, '2025-11-23', '2026-11-23', 'ACTIVE', 1),
('Card A2 - Flat Comb', 'Carding', 'BLOWROOM', 'Carding Section', 365, '2025-11-23', '2026-11-23', 'ACTIVE', 1),
('Card A3 - Flat Comb', 'Carding', 'BLOWROOM', 'Carding Section', 365, '2025-10-09', '2026-10-09', 'ACTIVE', 1),
('Card A4 - Flat Comb', 'Carding', 'BLOWROOM', 'Carding Section', 365, '2025-11-23', '2026-11-23', 'ACTIVE', 1),
('Card A5 - Flat Comb', 'Carding', 'BLOWROOM', 'Carding Section', 365, '2025-11-23', '2026-11-23', 'ACTIVE', 1),
('Card A6 - Flat Comb', 'Carding', 'BLOWROOM', 'Carding Section', 365, '2025-11-23', '2026-11-23', 'ACTIVE', 1),
('Card B1 - Flat Comb', 'Carding', 'BLOWROOM', 'Carding Section', 365, '2025-11-22', '2026-11-22', 'ACTIVE', 1),
('Card B2 - Flat Comb', 'Carding', 'BLOWROOM', 'Carding Section', 365, '2025-07-18', '2026-07-18', 'ACTIVE', 1),
('Card B3 - Flat Comb', 'Carding', 'BLOWROOM', 'Carding Section', 365, '2025-11-21', '2026-11-21', 'ACTIVE', 1),
('Card B4 - Flat Comb', 'Carding', 'BLOWROOM', 'Carding Section', 365, '2025-11-22', '2026-11-22', 'ACTIVE', 1),
('Card B5 - Flat Comb', 'Carding', 'BLOWROOM', 'Carding Section', 365, '2024-08-24', '2025-08-24', 'ACTIVE', 1),
('Card B6 - Flat Comb', 'Carding', 'BLOWROOM', 'Carding Section', 365, '2025-11-21', '2026-11-21', 'ACTIVE', 1);
