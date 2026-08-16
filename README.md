# MaintHub — Machine Maintenance Management System

[![Status](https://img.shields.io/badge/Status-In%20Development-yellow)]()
[![License](https://img.shields.io/badge/License-MIT-blue)](LICENSE)
[![Python](https://img.shields.io/badge/Python-3.9%2B-blue)](https://www.python.org/)
[![Flutter](https://img.shields.io/badge/Flutter-3.0%2B-blue)](https://flutter.dev)

A full-stack **Machine Maintenance Management System** for automating maintenance scheduling, notifications, and tracking. Built with Flask (Python) backend and Flutter mobile app.

> **Project Timeline:** August 2026 – November 2026 (16 weeks)  
> **Status:** Week 1-2 Complete (Backend & Frontend Built) ✅

---

## 🎯 Features

### ✅ Completed Features

**Backend (Flask API)**
- ✅ User authentication — login/register with JWT tokens
- ✅ Role-based access control — Admin vs Technician
- ✅ Machine management — CRUD operations for machines
- ✅ Auto-scheduling — next maintenance date calculation
- ✅ Maintenance tracking — complete maintenance history
- ✅ Dashboard KPIs — total, active, overdue, upcoming machines
- ✅ Notifications system — auto-generated alerts
- ✅ Background scheduler — APScheduler runs daily at 6 AM
- ✅ All 5 API routes implemented and tested

**Frontend (Flutter App)**
- ✅ Splash screen — auto-login check on app start
- ✅ Login/Register screens — email + password authentication
- ✅ Dashboard — KPI cards showing machine status overview
- ✅ Machine list — searchable, filterable machine registry
- ✅ Machine detail — view machine info + mark complete
- ✅ Add machine — admin-only form with date picker
- ✅ Pending maintenance — shows overdue machines only
- ✅ State management — Provider pattern for clean architecture
- ✅ API integration — Dio HTTP client with auto-JWT injection
- ✅ Secure storage — tokens stored in flutter_secure_storage

**Database (MySQL)**
- ✅ 4 core tables — users, machines, maintenance_history, notifications
- ✅ Schema auto-creation — init.sql runs on Docker startup
- ✅ Seed admin account — auto-created for first login
- ✅ Proper indexing — optimized queries for scheduler
- ✅ Foreign keys & cascades — data integrity maintained

### 🔄 In Progress

- 🟡 Equipment catalog — pre-loaded machine types with maintenance intervals (from Excel)
- 🟡 Add from catalog — quick-add machines from predefined list
- 🟡 Mobile refinements — better UX on small screens

### 📋 Not Yet Started

- ⬜ Email notifications — SMTP integration for alerts
- ⬜ QR code scanning — for machine tracking
- ⬜ Analytics dashboard — charts and reports
- ⬜ Multi-language support
- ⬜ Offline mode — sync when online

---

## 📊 Tech Stack

### Backend
| Component | Technology | Version |
|-----------|-----------|---------|
| Framework | Flask | 3.0.3 |
| ORM | SQLAlchemy | 2.0.19 |
| Database | MySQL | 8.0 |
| Auth | JWT (Flask-JWT-Extended) | 4.6.0 |
| Scheduler | APScheduler | 3.10.4 |
| Containerization | Docker | Latest |

### Frontend
| Component | Technology | Version |
|-----------|-----------|---------|
| Framework | Flutter | 3.0+ |
| State Mgmt | Provider | 6.1.2 |
| HTTP Client | Dio | 5.4.0 |
| Storage | flutter_secure_storage | 9.0.0 |
| Date Formatting | intl | 0.19.0 |

### Infrastructure (Production)
| Layer | Service | Purpose |
|-------|---------|---------|
| Database | Railway | Managed MySQL |
| Backend | Render | Flask deployment |
| Frontend | Google Play / Direct APK | Android distribution |

---

## 🚀 Quick Start

### Prerequisites
- Python 3.9+
- Flutter SDK 3.0+
- MySQL 8.0+ (or Docker)
- Git

### 30-Second Setup

**Backend:**
```bash
cd mainthub-backend
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
python run.py
# Backend at http://localhost:5000
```

**Database:**
```bash
# From repo root
docker-compose up -d mysql
```

**Frontend:**
```bash
cd mainthub-app
flutter pub get
flutter run
# Opens on Android emulator/device
```

---

## 📁 Project Structure

```
MainHub/
│
├── README.md                       ← You are here
├── CONTRIBUTING.md                 ← Team guidelines
├── DEPLOYMENT.md                   ← Production deploy guide
├── docker-compose.yml              ← MySQL + phpMyAdmin
├── init.sql                        ← Database schema
├── .gitignore
│
├── mainthub-backend/               ✅ COMPLETE
│   ├── run.py                      ← Start server
│   ├── requirements.txt            ← Python packages
│   ├── Dockerfile                  ← Container image
│   ├── .env.example
│   └── app/
│       ├── __init__.py            ← Flask factory + scheduler
│       ├── models/                ← SQLAlchemy models (4 tables)
│       ├── routes/                ← 5 API blueprints
│       └── services/              ← Business logic + scheduler
│
├── mainthub-app/                   ✅ COMPLETE
│   ├── pubspec.yaml               ← Flutter dependencies
│   ├── android/                   ← Android config
│   └── lib/
│       ├── main.dart              ← App entry point
│       ├── config/                ← Theme, URLs
│       ├── models/                ← Data classes (User, Machine, Dashboard)
│       ├── services/              ← API client + business logic
│       ├── providers/             ← State management (Auth, Machine)
│       └── screens/               ← 8 UI screens
│           ├── auth/              ← Login, Splash
│           ├── dashboard/         ← KPI overview
│           ├── machines/          ← List, detail, add
│           └── maintenance/       ← Pending maintenance
│
└── docs/                           ← Documentation
    ├── API_SPECIFICATION.md        ← All endpoints
    ├── DATABASE_SCHEMA.md          ← Table structure
    ├── DATABASE_GUIDE.md           ← How to use the DB
    ├── ARCHITECTURE.md             ← System design
    └── SETUP.md                    ← Detailed setup guide
```

---

## 🔌 API Endpoints (Complete List)

### Authentication
```
POST   /api/auth/register           Register new user
POST   /api/auth/login              Login user → access token
GET    /api/auth/me                 Get current user info
```

### Machines (CRUD)
```
GET    /api/machines/               List all machines
POST   /api/machines/               Create machine (admin only)
GET    /api/machines/<id>           Get machine details
PUT    /api/machines/<id>           Update machine (admin only)
DELETE /api/machines/<id>           Delete machine (admin only)
```

### Maintenance
```
POST   /api/maintenance/<id>/complete    Mark maintenance as done
GET    /api/maintenance/<id>/history     Get maintenance history
```

### Dashboard
```
GET    /api/dashboard/              Get KPI summary + recent maintenance
```

### Notifications
```
GET    /api/notifications/          Get user's notifications
PUT    /api/notifications/<id>/read Mark notification as read
```

Full API spec: See `docs/API_SPECIFICATION.md`

---

## 🗄️ Database Schema

**4 Core Tables:**

| Table | Purpose | Key Fields |
|-------|---------|-----------|
| `users` | User accounts | id, email, password_hash, role (ADMIN/TECHNICIAN) |
| `machines` | Equipment registry | id, name, type, next_maintenance_date, status |
| `maintenance_history` | Maintenance events | id, machine_id, technician_id, status (COMPLETED/OVERDUE) |
| `notifications` | Alerts sent to users | id, machine_id, user_id, type (REMINDER/OVERDUE) |

**Auto-Scheduling:**
- APScheduler runs daily at 6 AM
- Finds all machines with `next_maintenance_date <= TODAY()`
- Creates notifications for all technicians
- When technician marks complete → `next_maintenance_date` recalculates automatically

---

## 🔐 Default Login (Development)

| Field | Value |
|-------|-------|
| Email | admin@mainthub.com |
| Password | admin123 |
| Role | ADMIN |

**Change after first login in production!**

---

## 🧪 Testing

### Backend — Pytest

```bash
cd mainthub-backend
pytest                              # Run all tests
pytest --cov=app tests/             # With coverage
pytest tests/test_auth.py -v        # Specific test file
```

**Minimum coverage:** 70%

### Frontend — Flutter Test

```bash
cd mainthub-app
flutter test                        # Run all tests
flutter test test/providers/        # Test specific folder
```

---

## 🚀 Deployment

### Production Stack
- **Database:** Railway (MySQL managed)
- **Backend:** Render (Flask auto-deploy from GitHub)
- **Frontend:** Android APK (direct distribution or Play Store)

**See `DEPLOYMENT.md` for complete step-by-step guide.**

### Quick Deploy Checklist
- [ ] Push code to GitHub `main` branch
- [ ] Render auto-deploys Flask backend
- [ ] Update `app_config.dart` with Render URL
- [ ] Build APK: `flutter build apk --release`
- [ ] Distribute APK to team

---

## 📞 Team Workflow

### Branch Strategy
- `main` — production-ready code
- `develop` — integration branch (latest working)
- `feature/*` — new features
- `bugfix/*` — bug fixes

See `CONTRIBUTING.md` for detailed branching & commit conventions.

### Code Review
- Minimum 1 approval before merge
- No self-merging
- Address all comments before merge

### Daily Workflow
1. Pull latest `develop`
2. Create `feature/your-feature` branch
3. Commit with conventional commits (`feat:`, `fix:`, etc.)
4. Push and create Pull Request
5. Wait for review → merge
6. Delete branch

---

## 🆘 Troubleshooting

### Backend Won't Start
```bash
# Check Python version
python --version          # need 3.9+

# Reinstall dependencies
pip install -r requirements.txt

# Check database connection
echo $DATABASE_URL
```

### Flutter Build Fails
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run -v            # verbose for detailed errors
```

### Database Connection Error
```bash
# Check MySQL is running
docker ps                 # should show mainthub-mysql

# Check connection string format
DATABASE_URL=mysql+pymysql://user:pass@host:port/dbname
```

### API Calls Fail on Physical Device
```
Update app_config.dart with your PC's actual IP (192.168.x.x)
Not 10.0.2.2 — that only works on emulators
```

See `DEPLOYMENT.md` troubleshooting section for more.

---

## 📚 Documentation

| Document | What It Covers |
|----------|---------------|
| `README.md` | Project overview (this file) |
| `CONTRIBUTING.md` | Team guidelines, branching, commits, code style |
| `DEPLOYMENT.md` | Production deployment on Railway + Render |
| `docs/API_SPECIFICATION.md` | All REST endpoints with examples |
| `docs/DATABASE_SCHEMA.md` | Table structure and relationships |
| `docs/DATABASE_GUIDE.md` | Using MySQL, useful queries |
| `docs/ARCHITECTURE.md` | System design and patterns |

---

## 🎯 Next Steps (Week 2+)

### Week 2
- [ ] Load equipment catalog from Excel
- [ ] Add "Quick Add from Catalog" feature
- [ ] Add email notifications (SMTP)
- [ ] Polish UI based on feedback

### Week 3-4
- [ ] Analytics dashboard (charts, reports)
- [ ] Maintenance history filtering
- [ ] Technician assignment feature
- [ ] Export maintenance reports as PDF

### Week 5+
- [ ] QR code scanning for machines
- [ ] Offline mode (sync when online)
- [ ] Multi-language support
- [ ] Play Store submission

---

## 📊 Project Stats

| Metric | Value |
|--------|-------|
| Lines of Code | ~3500+ |
| Python Files | 15+ |
| Dart Files | 20+ |
| API Endpoints | 12 |
| Flutter Screens | 8 |
| Database Tables | 4 |
| Test Coverage Target | 70%+ |
| Team Size | 1-4 developers |

---

## 📅 Timeline Status

| Phase | Weeks | Status | Focus |
|-------|-------|--------|-------|
| **1: Foundation** | 1-2 | ✅ Done | Architecture, DB, Setup |
| **2: Core Features** | 3-5 | 🔄 In Progress | Catalog, Notifications |
| **3: Refinement** | 6-8 | 🔲 Next | Polish, Analytics |
| **4: Testing** | 9-11 | 🔲 Later | QA, Edge cases |
| **5: Deployment** | 12-13 | 🔲 Later | Production setup |
| **6: Documentation** | 14-16 | 🔲 Later | Final docs, demo |

---

## 🤝 Contributing

Read `CONTRIBUTING.md` for:
- How to set up your dev environment
- Branch naming conventions
- Commit message format
- Code style guidelines
- Pull request process
- Code review standards

**TL;DR:** Branch from `develop`, commit with `feat:` or `fix:`, push, create PR, get 1 approval, merge.

---

## 📜 License

This project is licensed under the **MIT License** — see `LICENSE` file for details.

---


---

## 🙋 Questions?

1. Check `docs/` folder for detailed guides
2. Check `CONTRIBUTING.md` for team standards
3. Check `DEPLOYMENT.md` for production questions
4. Ask in team chat (Slack/WhatsApp)
5. Create GitHub Issue for bugs/features

---

## ⭐ If This Helped

- ⭐ Star this repo
- 🍴 Fork for your own use
- 🐛 Report issues
- 💡 Suggest improvements
- 👥 Share with your team

---

**Happy coding! 🚀**

*Last updated: August 2026*  
*MainHub Team*
