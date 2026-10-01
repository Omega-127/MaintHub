# MaintHub — Database Operations Guide

This guide covers database setup, seeding, manual migrations, query patterns, and troubleshooting for **MaintHub**.

---

## 📋 Table of Contents
1. [Connection Strings](#1-connection-strings)
2. [Local Database with Docker](#2-local-database-with-docker)
3. [Auto-Migration & Seeding](#3-auto-migration--seeding)
4. [Department Data Breakdown](#4-department-data-breakdown)
5. [Useful Maintenance Queries](#5-useful-maintenance-queries)
6. [Backup & Restore](#6-backup--restore)
7. [Troubleshooting & Connection Pooling](#7-troubleshooting--connection-pooling)

---

## 1. Connection Strings

MaintHub automatically normalizes database connection strings via `_normalize_database_url()` in `app/__init__.py`.

### MySQL (Standard / Docker / Railway)
```env
DATABASE_URL=mysql+pymysql://mainthub_user:mainthub_pass@localhost:3306/mainthub_db
```

### Render PostgreSQL (if used)
```env
DATABASE_URL=postgresql+psycopg2://user:password@host:5432/dbname
```

### SQLite Fallback (Local Development)
If a local MySQL server is not detected on port 3306, the backend automatically falls back to an embedded SQLite database (`instance/mainthub.db`) for immediate offline testing:
```env
DATABASE_URL=sqlite:///mainthub.db
```

---

## 2. Local Database with Docker

The fastest way to spin up a fully configured MySQL 8.0 instance and phpMyAdmin GUI is using Docker Compose:

```bash
# Start MySQL and phpMyAdmin in background
docker-compose up -d

# Check container status
docker-compose ps
```

### Service Credentials

| Service | Host / URL | User | Password | Database |
|---------|-----------|------|----------|----------|
| **MySQL** | `localhost:3306` | `mainthub_user` | `mainthub_pass` | `mainthub_db` |
| **MySQL (Root)** | `localhost:3306` | `root` | `mainthub_root` | `mainthub_db` |
| **phpMyAdmin** | `http://localhost:8080` | `mainthub_user` | `mainthub_pass` | `mainthub_db` |

---

## 3. Auto-Migration & Seeding

### Automatic on Backend Boot
You do **not** need to manually run SQL scripts in normal development or production deployment. Every time the Flask backend starts, `_auto_migrate(app)` runs within `app/__init__.py`:

1. Verifies that `department` and `is_active` columns exist on `users` and `machines`.
2. Adds missing columns if not present via dynamic SQL statements.
3. Automatically creates the default administrator (`admin@mainthub.com` / `admin123`).
4. Checks the `machines` table against `seed.py` and seeds any missing equipment from all 6 departments.

### Manual Seeding via Python
To re-seed or run a standalone seed script:
```bash
cd mainthub-backend
python seed.py
```

### Manual Execution of SQL Scripts
If you prefer raw SQL execution:
```bash
# Apply complete schema and 295 machines
mysql -u mainthub_user -p mainthub_db < init.sql

# Or apply department migration script to existing database
mysql -u mainthub_user -p mainthub_db < migrate_add_departments.sql
```

---

## 4. Department Data Breakdown

MaintHub comes pre-loaded with **295 textile manufacturing machines** derived from real mill schedules across 6 specialized departments:

| Department Code | Department Name | Machine Count | Machine Types Included |
|-----------------|-----------------|---------------|------------------------|
| `BLOWROOM` | Preparatory / Blowroom | 24 | Bale Opener, Uniclean, Mono Cylinder, Step Cleaner, Carding |
| `COMBER` | Comber Department | 27 | Lap Former, Comber, Draw Frame |
| `RING_FRAME` | Ring Spinning | 37 | Ring Frame Lines RF-01 to RF-37 |
| `SPEED_FRAME` | Speed Frame / Roving | 50 | Speed Frame SF-01 to SF-50, Simplex Frames |
| `WINDING` | Autoconer / Winding | 105 | Autoconer AC-01 to AC-105, Murata Process Coners |
| `BUFFING` | Maintenance & Buffing | 52 | Cot Buffing, Roller Grinder, Arbour Cleaning |
| **TOTAL** | **All Departments** | **295** | Full Textile Mill Machinery |

---

## 5. Useful Maintenance Queries

### Check Machine Distribution by Department & Status
```sql
SELECT
    department,
    status,
    COUNT(*) AS machine_count
FROM machines
GROUP BY department, status
ORDER BY department, machine_count DESC;
```

### Identify Overdue Machines Across All Departments
```sql
SELECT
    id,
    name,
    type,
    department,
    next_maintenance_date,
    DATEDIFF(CURRENT_DATE, next_maintenance_date) AS days_overdue
FROM machines
WHERE status = 'ACTIVE' AND next_maintenance_date < CURRENT_DATE
ORDER BY days_overdue DESC;
```

### Maintenance Work Completed in the Last 30 Days
```sql
SELECT
    mh.id,
    m.name AS machine_name,
    m.department,
    u.full_name AS technician_name,
    mh.maintenance_date,
    mh.notes
FROM maintenance_history mh
JOIN machines m ON mh.machine_id = m.id
JOIN users u ON mh.technician_id = u.id
WHERE mh.maintenance_date >= DATE_SUB(NOW(), INTERVAL 30 DAY)
ORDER BY mh.maintenance_date DESC;
```

### Summary of Pending Alerts / Notifications
```sql
SELECT
    notification_type,
    is_read,
    COUNT(*) AS alert_count
FROM notifications
GROUP BY notification_type, is_read;
```

---

## 6. Backup & Restore

### Create a Database Backup
```bash
# Using Docker
docker exec mainthub-mysql mysqldump -u root -pmainthub_root mainthub_db > backup_$(date +%Y%m%d).sql

# Using local MySQL client
mysqldump -h localhost -u mainthub_user -p mainthub_db > backup.sql
```

### Restore a Database Backup
```bash
# Using Docker
docker exec -i mainthub-mysql mysql -u root -pmainthub_root mainthub_db < backup.sql

# Using local MySQL client
mysql -h localhost -u mainthub_user -p mainthub_db < backup.sql
```

---

## 7. Troubleshooting & Connection Pooling

### MySQL Disconnection / Timeout on Render/Railway
Cloud database platforms (like Railway) frequently close idle TCP connections after 300 seconds. If an application attempts to use a closed socket, SQLAlchemy throws:
`MySQL server has gone away (2006)` or `OperationalError`.

**How MaintHub handles this:**
In `mainthub-backend/app/__init__.py`, connection pooling options are explicitly configured:
```python
app.config["SQLALCHEMY_ENGINE_OPTIONS"] = {
    "pool_pre_ping": True,  # Checks connection liveness before every query
    "pool_recycle": 280,    # Recycles connections every 280 seconds (before 300s timeout)
}
```

### Resyncing Machines if Seeding Failed
If you ever want to force a full re-sync of machines:
```sql
-- View existing count
SELECT COUNT(*) FROM machines;

-- If you need to clear and let auto-migration resync:
-- DELETE FROM maintenance_history;
-- DELETE FROM notifications;
-- DELETE FROM machines;
-- Restarting backend will re-seed all 295 machines automatically!
```
