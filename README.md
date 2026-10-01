# MaintHub — Machine Maintenance Management System

[![Status](https://img.shields.io/badge/Status-Production%20Ready-brightgreen)]()
[![License](https://img.shields.io/badge/License-MIT-blue)](LICENSE)
[![Python](https://img.shields.io/badge/Python-3.9%2B-blue)](https://www.python.org/)
[![Flask](https://img.shields.io/badge/Flask-3.0.3-black)](https://flask.palletsprojects.com/)
[![Flutter](https://img.shields.io/badge/Flutter-3.0%2B-blue)](https://flutter.dev)
[![Database](https://img.shields.io/badge/Database-MySQL%208.0%20%7C%20SQLite-orange)](https://www.mysql.com/)

A modern, full-stack **Machine Maintenance Management System (CMMS)** designed for industrial textile manufacturing facilities. Automates equipment maintenance scheduling, predictive overdue alerting, technician assignments, and service history tracking across all manufacturing departments.

Built with a high-performance **Python/Flask** backend, **MySQL** database with connection pooling and auto-migration, and a cross-platform **Flutter** mobile application.

---

## 🎯 Key Highlights

- **🏭 6 Textile Mill Departments:** Full support for `BLOWROOM`, `COMBER`, `RING_FRAME`, `SPEED_FRAME`, `WINDING`, and `BUFFING`.
- **⚙️ 295 Pre-Seeded Machines:** Complete catalog synchronized directly from industry maintenance schedules.
- **👥 Role-Based Access Control (RBAC):**
  - **Technicians:** Automatically scoped to their assigned department to view relevant machinery, upcoming tasks, and overdue alerts.
  - **Administrators:** Facility-wide visibility with instant department-switching tabs, equipment CRUD, and scheduling management.
- **⚡ Self-Healing Database & Auto-Migration:** Automated schema migrations (`_auto_migrate`) and default administrator provisioning on startup.
- **⏰ Automated Background Scheduler:** Daily background evaluation (APScheduler at 06:00 AM) that detects due machinery and dispatches in-app notifications.
- **🛡️ Cloud Connection Resilience:** Engineered with pre-pinging (`pool_pre_ping=True`) and connection recycling (`pool_recycle=280`) to eliminate cloud database disconnects on Render and Railway, plus SQLite fallback for offline local testing.

---

## 🚀 Features Breakdown

### ✅ Backend (Flask 3.0 REST API)
- ✅ **Authentication & Authorization:** Secure JWT access tokens with BCrypt password hashing and role enforcement.
- ✅ **Department Scoping:** Automated query filtering matching the technician's assigned department.
- ✅ **Equipment Management:** Full CRUD operations for machinery with customizable service intervals (days).
- ✅ **Automated Next-Date Engine:** Recalculates `next_maintenance_date = today + interval` automatically upon maintenance completion.
- ✅ **Maintenance History:** Complete audit trail of service events, notes, timestamps, and technician IDs.
- ✅ **Executive Dashboard:** Aggregates facility KPIs (Total, Active, Inactive, Under Maintenance, Overdue, and Upcoming 7-day machinery).
- ✅ **Background Scheduler:** APScheduler daily 6:00 AM worker generating reminders and overdue alerts.
- ✅ **Health Check Endpoints:** `/health` and `/api/health` probes for cloud uptime and database monitoring.

### ✅ Frontend (Flutter Mobile App)
- ✅ **Splash & Auto-Authentication:** Token verification on app start with hardware-backed secure storage.
- ✅ **Role-Aware Registration & Login:** Technicians select their designated department during signup; Admins manage all departments.
- ✅ **Interactive Dashboard:** Live KPI stat cards with department filtering tabs and quick-action overdue alerts.
- ✅ **Searchable Machine Registry:** Real-time search across machine name, model, type, and location.
- ✅ **Actionable Machine Details:** View equipment specifications, next scheduled maintenance, and log completed service.
- ✅ **Add Machine Form:** Admin-exclusive screen with interval configuration and date picker.
- ✅ **Pending Maintenance Queue:** Dedicated view highlighting machines that are overdue for servicing.
- ✅ **Clean Architecture:** Provider state management (`AuthProvider`, `MachineProvider`) and Dio HTTP client with JWT interceptor.

### ✅ Database & Infrastructure
- ✅ **4 Core Relational Tables:** `users`, `machines`, `maintenance_history`, and `notifications`.
- ✅ **Dockerized Environment:** Pre-configured MySQL 8.0 and phpMyAdmin in `docker-compose.yml`.
- ✅ **Zero-Downtime Deployment:** Tested on Railway (managed MySQL) and Render (Gunicorn web service).

---

## 📊 Tech Stack

| Domain | Technology | Version | Purpose |
|--------|------------|---------|---------|
| **Backend Framework** | Flask | 3.0.3 | High-performance RESTful API |
| **ORM & Database Client** | SQLAlchemy / PyMySQL | 2.0.19 / 1.1.0 | Database abstraction & connection pooling |
| **Database** | MySQL / SQLite | 8.0 | Relational database (SQLite local fallback) |
| **Authentication** | Flask-JWT-Extended | 4.6.0 | Stateless Bearer token auth |
| **Password Security** | BCrypt | 4.1.2 | Cryptographic password hashing |
| **Background Scheduler** | APScheduler | 3.10.4 | Daily cron evaluation of service dates |
| **WSGI Server** | Gunicorn | 21.2.0 | Production-grade WSGI HTTP server |
| **Mobile Framework** | Flutter / Dart | 3.0+ | Cross-platform Android & iOS client |
| **State Management** | Provider | 6.1.2 | Reactive application state |
| **Mobile Networking** | Dio | 5.4.0 | HTTP client with automatic token interceptor |
| **Secure KeyStore** | flutter_secure_storage | 9.0.0 | Hardware-backed encrypted storage |

---

## 📁 Repository Structure

```
MaintHub/
├── README.md                           ← Master overview (this file)
├── CONTRIBUTING.md                     ← Team collaboration & Git Flow guidelines
├── DEPLOYMENT.md                       ← Production deployment on Railway + Render
├── NOTIFICATIONS_GUIDE.md              ← Background scheduler & notification engine
├── docker-compose.yml                  ← Local MySQL 8.0 & phpMyAdmin services
├── init.sql                            ← Database DDL schema & 295 machine seeds
├── migrate_add_departments.sql         ← Standalone migration script
├── render.yaml                         ← Render Infrastructure-as-Code manifest
├── LICENSE                             ← MIT License
│
├── docs/                               ← 📚 Detailed Documentation Suite
│   ├── API_SPECIFICATION.md            ← Exhaustive REST API specification & payloads
│   ├── DATABASE_SCHEMA.md              ← Entity diagrams, table schemas & indexes
│   ├── DATABASE_GUIDE.md               ← DB setup, seeding, queries & pooling guide
│   ├── ARCHITECTURE.md                 ← Multi-tier system architecture & RBAC model
│   └── SETUP.md                        ← Step-by-step local developer setup guide
│
├── mainthub-backend/                   ← 🐍 Flask Backend Service
│   ├── README.md                       ← Backend specific documentation
│   ├── run.py                          ← Server entry point
│   ├── seed.py                         ← Machine catalog definitions (295 machines)
│   ├── Dockerfile                      ← Container specification
│   ├── Procfile                        ← Gunicorn web process definition
│   ├── render.yaml                     ← Service configuration for Render
│   ├── requirements.txt                ← Python package dependencies
│   └── app/
│       ├── __init__.py                 ← App factory, connection pooling, auto-migration
│       ├── models/                     ← SQLAlchemy database models
│       ├── routes/                     ← REST API Blueprints (Auth, Machines, etc.)
│       └── services/                   ← Scheduler background service
│
├── mainthub-app/                       ← 📱 Flutter Mobile Application
│   ├── README.md                       ← Mobile app documentation & APK build instructions
│   ├── pubspec.yaml                    ← Flutter dependencies
│   └── lib/
│       ├── main.dart                   ← Mobile entry point
│       ├── config/                     ← API URLs (app_config.dart), theme
│       ├── models/                     ← Data classes (User, Machine, Dashboard)
│       ├── providers/                  ← State stores (AuthProvider, MachineProvider)
│       ├── services/                   ← Dio API client & service wrappers
│       └── screens/                    ← UI Screens (Auth, Dashboard, Machines, etc.)
│
└── *.xlsx                              ← Industry Maintenance Schedule Spreadsheets
    ├── comber_schedules.xlsx
    ├── Preparatory_Buffing_Schedule.xlsx
    ├── Ring_Frame_Maintenance_Schedule.xlsx
    ├── Speed_Frame_Maintenance_Schedule.xlsx
    └── Winding_Maintenance_Schedule.xlsx
```

---

## ⚡ Quick Start

### 1. Database & Backend
```bash
# Clone the repository
git clone https://github.com/Omega-127/MaintHub.git
cd MaintHub

# Start MySQL database in Docker (optional — SQLite auto-fallback is supported)
docker-compose up -d mysql

# Setup Python environment
cd mainthub-backend
python -m venv venv
.\venv\Scripts\activate          # Windows PowerShell (or source venv/bin/activate on Unix)
pip install -r requirements.txt

# Run backend (auto-migrates schema and syncs 295 machines)
python run.py
# Server runs on http://localhost:5000
```

### 2. Flutter Mobile App
```bash
cd ../mainthub-app
flutter pub get

# Configure backend URL in lib/config/app_config.dart
# - For Android Emulator: 'http://10.0.2.2:5000/api'
# - For Physical Device:  'http://<YOUR_LOCAL_IP>:5000/api'
# - For Production:       'https://mainthub-backend.onrender.com/api'

flutter run
```

---

## 🔐 Default Administrator Login

The backend automatically provisions an administrator account on first launch:

| Credential | Value |
|------------|-------|
| **Email** | `admin@mainthub.com` |
| **Password** | `admin123` |
| **Role** | `ADMIN` |
| **Department Access** | Full mill-wide access (all 6 departments) |

> 🔒 **Security Notice:** Always update the default administrator password in production environments!

---

## 🔌 API Endpoints Summary

| Blueprint | Method | Endpoint | Description | Access |
|-----------|--------|----------|-------------|--------|
| **Health** | `GET` | `/health`, `/api/health` | Service and database probe | Public |
| **Auth** | `POST` | `/api/auth/register` | Register new user / technician | Public |
| **Auth** | `POST` | `/api/auth/login` | Login and obtain JWT token | Public |
| **Auth** | `GET` | `/api/auth/me` | Current authenticated profile | Authenticated |
| **Machines** | `GET` | `/api/machines/` | List machines (dept scoped) | Authenticated |
| **Machines** | `GET` | `/api/machines/types` | List distinct machine types | Authenticated |
| **Machines** | `GET` | `/api/machines/departments`| List 6 textile departments | Authenticated |
| **Machines** | `GET` | `/api/machines/due` | List overdue machines | Authenticated |
| **Machines** | `GET` | `/api/machines/<id>` | Get single machine details | Authenticated |
| **Machines** | `POST` | `/api/machines/` | Register new machine | Admin Only |
| **Machines** | `PUT` | `/api/machines/<id>` | Update machine specifications | Admin Only |
| **Machines** | `DELETE`| `/api/machines/<id>` | Remove machine from registry | Admin Only |
| **Maintenance** | `POST` | `/api/maintenance/<id>/complete` | Log completed maintenance | Authenticated |
| **Maintenance** | `GET` | `/api/maintenance/<id>/history` | View machine service history | Authenticated |
| **Maintenance** | `GET` | `/api/maintenance/due` | Query due machinery | Authenticated |
| **Dashboard** | `GET` | `/api/dashboard/` | Real-time facility KPIs | Authenticated |
| **Notifications**| `GET` | `/api/notifications/` | Get user in-app alerts | Authenticated |
| **Notifications**| `PUT` | `/api/notifications/<id>/read` | Mark alert as acknowledged | Authenticated |

Detailed schemas, query parameters, and JSON payloads: see [`docs/API_SPECIFICATION.md`](docs/API_SPECIFICATION.md).

---

## 🏭 Department Catalog Summary

| Department | Equipment Types | Seeded Count |
|------------|-----------------|--------------|
| **BLOWROOM** | Bale Opener, Uniclean, Mono Cylinder, Carding | 24 |
| **COMBER** | Lap Former, Comber, Draw Frame | 27 |
| **RING FRAME** | Ring Spinning Frames RF-01 to RF-37 | 37 |
| **SPEED FRAME** | Speed / Roving Frames SF-01 to SF-50 | 50 |
| **WINDING** | Autoconers AC-01 to AC-105 | 105 |
| **BUFFING** | Cot Buffing & Maintenance Equipment | 52 |
| **TOTAL** | **Comprehensive Textile Mill Inventory** | **295 Machines** |

---

## 📚 Complete Documentation Index

| Guide | Description |
|-------|-------------|
| [**API Specification**](docs/API_SPECIFICATION.md) | Full endpoint contracts, request/response bodies, HTTP codes, and RBAC rules |
| [**Database Schema**](docs/DATABASE_SCHEMA.md) | Entity relationship diagram, table structures, column constraints, and indexes |
| [**Database Operations Guide**](docs/DATABASE_GUIDE.md) | Docker setup, auto-migration engine, maintenance queries, and connection pooling |
| [**System Architecture**](docs/ARCHITECTURE.md) | Architecture diagram, component design, state management, and security model |
| [**Local Setup Guide**](docs/SETUP.md) | Step-by-step developer onboarding for Windows, macOS, Linux, and Android |
| [**Deployment Guide**](DEPLOYMENT.md) | Production deployment instructions for Railway (MySQL) and Render (Flask) |
| [**Notifications Guide**](NOTIFICATIONS_GUIDE.md) | APScheduler job execution, overdue criteria, and alert delivery |
| [**Contributing Guide**](CONTRIBUTING.md) | Branching guidelines, conventional commits, code review standards |
| [**Mobile App Guide**](mainthub-app/README.md) | Flutter application architecture, screen flows, and APK release generation |
| [**Backend Guide**](mainthub-backend/README.md) | Flask server setup, environment variables, and Docker containerization |

---

## 🤝 Contributing

We welcome contributions! Please review [`CONTRIBUTING.md`](CONTRIBUTING.md) before submitting pull requests.

1. Create a feature branch: `git checkout -b feature/your-feature`
2. Commit your changes following [Conventional Commits](https://www.conventionalcommits.org/): `git commit -m 'feat: add equipment report export'`
3. Push to the branch: `git push origin feature/your-feature`
4. Open a Pull Request for review.

---

## 📜 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
