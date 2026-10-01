# MaintHub Backend Service (`mainthub-backend`)

[![Python](https://img.shields.io/badge/Python-3.9%2B-blue)](https://www.python.org/)
[![Flask](https://img.shields.io/badge/Flask-3.0.3-black)](https://flask.palletsprojects.com/)
[![License](https://img.shields.io/badge/License-MIT-green)](../LICENSE)
[![Status](https://img.shields.io/badge/Status-Production%20Ready-brightgreen)]()

The REST API backend for **MaintHub**, managing equipment registries, technician authentication, automated maintenance intervals, APScheduler background alerting, and database operations across 6 textile mill departments.

---

## ⚡ Core Features

- **Department-Scoped Multi-Tenancy:**
  - Automated role-based access control (RBAC).
  - Admins can query all departments or filter by department.
  - Technicians are automatically scoped to their designated department (`BLOWROOM`, `COMBER`, `RING_FRAME`, `SPEED_FRAME`, `WINDING`, `BUFFING`).
- **Pre-Seeded Machinery Catalog:**
  - Synchronizes 295 textile manufacturing machines across all 6 departments on startup.
- **Self-Healing Schema & Auto-Migration:**
  - `_auto_migrate(app)` verifies and dynamically applies schema alterations (e.g. `department`, `is_active` columns).
  - Automatically provisions default administrator credentials (`admin@mainthub.com` / `admin123`).
- **Resilient Connection Pooling:**
  - Configured with `pool_pre_ping=True` and `pool_recycle=280` to prevent cloud database socket timeouts (Railway, Render).
  - SQLite auto-fallback when running locally without a MySQL server running on port 3306.
- **Automated Background Scheduler:**
  - APScheduler job triggers daily at 6:00 AM to evaluate overdue machines and dispatch alerts.
- **Health Monitoring Endpoints:**
  - `/health` and `/api/health` probes for container orchestrators and Render uptime checks.

---

## 📁 Directory Structure

```
mainthub-backend/
├── app/
│   ├── __init__.py           # Flask application factory, DB pool config, auto-migrate
│   ├── models/               # SQLAlchemy ORM models
│   │   ├── user.py           # User entity (Admin / Technician, department scoping)
│   │   ├── machine.py        # Machine entity (interval, dates, department)
│   │   ├── maintenance.py    # MaintenanceHistory entity
│   │   └── notification.py   # Notification entity
│   ├── routes/               # REST API Blueprints
│   │   ├── auth.py           # /api/auth (register, login, me)
│   │   ├── machines.py       # /api/machines (CRUD, types, departments, due)
│   │   ├── maintenance.py    # /api/maintenance (complete, history, due)
│   │   ├── dashboard.py      # /api/dashboard (KPIs, overdue summaries)
│   │   └── notifications.py  # /api/notifications (alerts, mark-as-read)
│   └── services/
│       └── scheduler.py      # Background APScheduler service
├── instance/                 # Local SQLite database fallback storage
├── seed.py                   # 295 machine catalog definitions across 6 departments
├── run.py                    # Entry point script
├── Dockerfile                # Production container specification
├── Procfile                  # Gunicorn web service process definition
├── render.yaml               # Render infrastructure blueprint
└── requirements.txt          # Python dependencies
```

---

## 🔧 Environment Variables

Configure these in a `.env` file in `mainthub-backend/`:

| Variable | Description | Example / Default |
|----------|-------------|-------------------|
| `DATABASE_URL` | SQLAlchemy connection string | `mysql+pymysql://mainthub_user:mainthub_pass@localhost:3306/mainthub_db` |
| `JWT_SECRET_KEY` | Secret key used to sign JWT tokens | `generate-a-strong-random-32-char-key` |
| `FLASK_ENV` | Environment mode | `development` or `production` |
| `PORT` | Listening port for web server | `5000` |

---

## 🚀 Local Development Setup

### 1. Create and Activate Virtual Environment

**Windows (PowerShell):**
```powershell
python -m venv venv
.\venv\Scripts\Activate.ps1
```

**macOS / Linux:**
```bash
python3 -m venv venv
source venv/bin/activate
```

### 2. Install Dependencies
```bash
pip install --upgrade pip
pip install -r requirements.txt
```

### 3. Start Server
```bash
python run.py
```

The application runs on `http://localhost:5000` with auto-migration and automatic catalog syncing.

---

## 🔌 API Routes Summary

| Method | Endpoint | Description | Access Tier |
|--------|----------|-------------|-------------|
| `GET` | `/health` | Health and DB connectivity check | Public |
| `POST` | `/api/auth/register` | Register new admin or technician | Public |
| `POST` | `/api/auth/login` | Login and receive JWT access token | Public |
| `GET` | `/api/auth/me` | Current user profile | Authenticated |
| `GET` | `/api/machines/` | List machines (dept filtered for tech) | Authenticated |
| `GET` | `/api/machines/types` | List distinct machine categories | Authenticated |
| `GET` | `/api/machines/departments`| List 6 valid departments | Authenticated |
| `GET` | `/api/machines/due` | List overdue machinery | Authenticated |
| `GET` | `/api/machines/<id>` | Single machine details | Authenticated |
| `POST` | `/api/machines/` | Create machine & set schedule | Admin Only |
| `PUT` | `/api/machines/<id>` | Update machine details | Admin Only |
| `DELETE` | `/api/machines/<id>`| Remove machine | Admin Only |
| `POST` | `/api/maintenance/<id>/complete` | Log maintenance done | Authenticated |
| `GET` | `/api/maintenance/<id>/history` | Machine maintenance history | Authenticated |
| `GET` | `/api/dashboard/` | Real-time KPIs & overdue widget | Authenticated |
| `GET` | `/api/notifications/` | In-app alerts | Authenticated |
| `PUT` | `/api/notifications/<id>/read` | Mark alert read | Authenticated |

For detailed payloads, status codes, and JSON schemas, see [`../docs/API_SPECIFICATION.md`](../docs/API_SPECIFICATION.md).

---

## 🧪 Testing

Run automated tests with `pytest`:

```bash
# Run test suite
pytest

# Run with test coverage report
pytest --cov=app tests/
```

---

## 🐳 Docker Execution

```bash
# Build image
docker build -t mainthub-backend .

# Run container
docker run -p 5000:5000 \
  -e DATABASE_URL="mysql+pymysql://mainthub_user:mainthub_pass@host.docker.internal:3306/mainthub_db" \
  -e JWT_SECRET_KEY="production-secret" \
  mainthub-backend
```
