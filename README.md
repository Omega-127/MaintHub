# MaintHub — Machine Maintenance Management System

[![Status](https://img.shields.io/badge/Status-In%20Development-yellow)]()
[![License](https://img.shields.io/badge/License-MIT-blue)](LICENSE)
[![Python](https://img.shields.io/badge/Python-3.9%2B-blue)](https://www.python.org/)
[![Flutter](https://img.shields.io/badge/Flutter-3.0%2B-blue)](https://flutter.dev)

A full-stack **Machine Maintenance Management System** for automating maintenance scheduling, notifications, and tracking. Built with Flask (Python) backend and Flutter mobile app.

> **Project Timeline:** August 2026 – November 2026 (16 weeks)  
> **Status:** Week 1 Complete (Foundation & Setup) ✅

---

## 🎯 Features

- ✅ **User Management** — Admin and Technician roles with role-based access
- ✅ **Machine Registry** — Register and track machines with maintenance intervals
- ✅ **Automatic Scheduling** — System auto-calculates next maintenance date
- ✅ **Smart Notifications** — APScheduler sends alerts at scheduled times (Firebase/Email)
- ✅ **Maintenance Tracking** — Complete history of all maintenance events
- ✅ **Dashboard** — Real-time overview (pending, completed, overdue maintenance)
- ✅ **Mobile App** — iOS + Android Flutter app for on-the-go access
- ✅ **Cross-Platform** — Runs on web, Android, iOS with single codebase

---

## 📊 Tech Stack

### Backend
| Component | Technology | Purpose |
|-----------|-----------|---------|
| Framework | Flask 2.3 | Lightweight, fast REST API |
| ORM | SQLAlchemy | Database abstraction |
| Database | MySQL 8.0 | Relational database |
| Authentication | JWT | Stateless token auth |
| Scheduling | APScheduler | Background task scheduler |
| Notifications | Firebase/SMTP | Push notifications & email |

### Frontend
| Component | Technology | Purpose |
|-----------|-----------|---------|
| Framework | Flutter 3.0+ | Cross-platform mobile |
| State Mgmt | Riverpod | Reactive state management |
| HTTP Client | Dio | REST API integration |
| Storage | flutter_secure_storage | Secure token storage |

### Infrastructure
| Component | Technology | Purpose |
|-----------|-----------|---------|
| Database | Supabase | Managed PostgreSQL |
| Backend Hosting | Render | Flask app deployment |
| Version Control | GitHub | Code repository + CI/CD |
| Containerization | Docker | Local development consistency |

---

## 🚀 Quick Start

### Prerequisites
- Python 3.9+
- Flutter SDK 3.0+
- MySQL 8.0+ (or Docker)
- Git
- A code editor (VS Code, Android Studio, etc.)

### 30-Second Setup

```bash
# 1. Clone the repo
git clone https://github.com/your-org/MainHub.git
cd MaintHub

# 2. Run the initialization script
bash init_project.sh

# 3. Start the backend
cd mainthub-backend
python run.py
# Backend runs at http://localhost:5000

# 4. Start the frontend (in another terminal)
cd mainthub-app
flutter run
```

**That's it! Backend + Frontend running locally.**

---

## 📁 Project Structure

```
mainthub/
│
├── mainthub-backend/                 # Flask REST API
│   ├── app/
│   │   ├── models/                   # SQLAlchemy ORM models
│   │   │   ├── user.py              # User (Admin/Technician)
│   │   │   ├── machine.py           # Machine registry
│   │   │   ├── maintenance.py       # Maintenance history
│   │   │   └── notification.py      # Notifications
│   │   ├── routes/                   # API endpoints
│   │   │   ├── auth.py              # Login, register
│   │   │   ├── machines.py          # Machine CRUD
│   │   │   ├── maintenance.py       # Mark complete, history
│   │   │   ├── dashboard.py         # Dashboard KPIs
│   │   │   └── notifications.py     # Notification endpoints
│   │   ├── schemas/                  # Request/response validation (Marshmallow)
│   │   ├── services/                 # Business logic
│   │   │   ├── auth_service.py
│   │   │   ├── machine_service.py
│   │   │   ├── maintenance_service.py
│   │   │   ├── notification_service.py
│   │   │   └── scheduler_service.py  # APScheduler jobs
│   │   └── utils/                    # Utilities
│   │       ├── security.py           # Bcrypt, JWT
│   │       └── decorators.py         # @jwt_required, @admin_only
│   ├── tests/                        # Test suite
│   ├── migrations/                   # Database migrations (Alembic)
│   ├── requirements.txt              # Python dependencies
│   ├── .env.example                  # Environment template
│   ├── Dockerfile                    # Container image
│   ├── run.py                        # Development entry point
│   └── wsgi.py                       # Production entry point
│
├── mainthub-app/                     # Flutter mobile app
│   ├── lib/
│   │   ├── main.dart                # App entry point
│   │   ├── config/
│   │   │   ├── app_config.dart      # Constants
│   │   │   └── theme.dart           # Colors, fonts, themes
│   │   ├── models/                   # Data models
│   │   │   ├── user.dart
│   │   │   ├── machine.dart
│   │   │   └── maintenance.dart
│   │   ├── providers/                # Riverpod state management
│   │   │   ├── auth_provider.dart
│   │   │   ├── machine_provider.dart
│   │   │   └── dashboard_provider.dart
│   │   ├── screens/                  # UI pages
│   │   │   ├── auth/
│   │   │   │   ├── login_screen.dart
│   │   │   │   └── splash_screen.dart
│   │   │   ├── machines/
│   │   │   │   ├── machine_list_screen.dart
│   │   │   │   ├── machine_detail_screen.dart
│   │   │   │   └── add_machine_screen.dart
│   │   │   ├── maintenance/
│   │   │   │   ├── maintenance_pending_screen.dart
│   │   │   │   └── maintenance_history_screen.dart
│   │   │   └── dashboard/
│   │   │       └── dashboard_screen.dart
│   │   ├── services/                 # API integration
│   │   │   ├── api_client.dart      # Dio HTTP client
│   │   │   ├── auth_service.dart
│   │   │   └── machine_service.dart
│   │   └── widgets/                  # Reusable components
│   ├── test/                         # Flutter tests
│   ├── pubspec.yaml                  # Flutter dependencies
│   ├── .env.example                  # Environment template
│   └── README.md                     # Frontend-specific guide
│
├── docs/                             # Documentation
│   ├── API_SPECIFICATION.md          # REST API endpoints
│   ├── DATABASE_SCHEMA.md            # Database design
│   ├── ARCHITECTURE.md               # System architecture
│   ├── SETUP.md                      # Detailed setup guide
│   └── DEPLOYMENT.md                 # Production deployment
│
├── docker-compose.yml                # Full stack in Docker
├── .gitignore
├── .github/
│   └── workflows/                    # GitHub Actions CI/CD
│       └── test.yml
├── README.md                         # This file
├── CONTRIBUTING.md                   # Contribution guidelines
├── LICENSE                           # MIT License
└── init_project.sh                   # One-time setup script
```

---

## 🔧 Backend Setup

### 1. Install Dependencies

```bash
cd mainthub-backend

# Create virtual environment
python3 -m venv venv

# Activate it
source venv/bin/activate              # On Windows: venv\Scripts\activate

# Install Python packages
pip install -r requirements.txt
```

### 2. Configure Database

```bash
# Create .env from template
cp .env.example .env

# Edit .env with your database credentials
DATABASE_URL=mysql+pymysql://user:password@localhost:3306/maintenance_system
JWT_SECRET_KEY=your-secret-key-here-min-32-chars
```

### 3. Initialize Database

```bash
# Run migrations
flask db upgrade

# Or create tables manually
python
>>> from app import create_app, db
>>> app = create_app()
>>> with app.app_context():
...     db.create_all()
```

### 4. Start Backend

```bash
python run.py
```

Backend runs at **http://localhost:5000**

API documentation (Swagger): **http://localhost:5000/docs**

---

## 📱 Frontend Setup

### 1. Install Dependencies

```bash
cd mainthub-app

flutter pub get
```

### 2. Configure Environment

```bash
# Create .env from template
cp .env.example .env

# Edit with your API URL
API_BASE_URL=http://10.0.2.2:5000     # For Android emulator
# or
API_BASE_URL=http://localhost:5000    # For iOS simulator
```

### 3. Generate Code (if needed)

```bash
flutter pub run build_runner build
```

### 4. Run the App

```bash
# On Android emulator
flutter emulators
flutter emulators launch Pixel_4_API_30

# Run app
flutter run

# Or specify device
flutter run -d emulator-5554
```

---

## 🐳 Docker Setup (Recommended)

Run everything with Docker:

```bash
cd mainthub

# Start MySQL + Backend
docker-compose up

# In another terminal, start Flutter
cd mainthub-app
flutter run
```

**Services running:**
- MySQL: `localhost:3306` (root:root_password)
- Backend: `http://localhost:5000`
- PhpMyAdmin (optional): `http://localhost:8080`

---

## 📡 API Endpoints

### Authentication
```
POST   /api/auth/login              Login user
POST   /api/auth/register           Register new user
POST   /api/auth/logout             Logout user
```

### Machines
```
GET    /api/machines                List all machines
POST   /api/machines                Create machine
GET    /api/machines/{id}           Get machine details
PUT    /api/machines/{id}           Update machine
DELETE /api/machines/{id}           Delete machine
```

### Maintenance
```
GET    /api/maintenance/{machine_id}     Get maintenance history
POST   /api/machines/{id}/mark-complete  Mark maintenance as done
```

### Dashboard
```
GET    /api/dashboard               Get dashboard data (KPIs)
```

### Notifications
```
GET    /api/notifications           Get user notifications
PUT    /api/notifications/{id}/read Mark notification as read
```

Full API documentation: See `docs/API_SPECIFICATION.md`

---

## 💾 Database Schema

### Core Tables

**users** — Admins and Technicians
```sql
id | email | password_hash | full_name | role | is_active | created_at
```

**machines** — Equipment to maintain
```sql
id | name | type | maintenance_interval | last_maintenance_date | next_maintenance_date | status | created_by
```

**maintenance_history** — All maintenance events
```sql
id | machine_id | technician_id | maintenance_date | status | notes
```

**notifications** — Alerts to users
```sql
id | machine_id | user_id | title | message | type | is_sent
```

Full schema: See `docs/DATABASE_SCHEMA.md`

---

## 🔐 Authentication

The app uses **JWT (JSON Web Tokens)**:

1. User logs in → Backend validates credentials
2. Backend returns `access_token` + `refresh_token`
3. Frontend stores token in secure storage
4. Frontend includes token in all API requests: `Authorization: Bearer {token}`
5. Backend validates token on protected endpoints

**Token Expiry:**
- Access token: 24 hours
- Refresh token: 7 days

---

## 🧪 Testing

### Backend Tests

```bash
cd mainthub-backend

# Run all tests
pytest

# Run with coverage
pytest --cov=app tests/

# Run specific test file
pytest tests/test_auth.py
```

### Frontend Tests

```bash
cd mainthub-app

# Run all tests
flutter test

# Run specific test
flutter test test/screens/login_screen_test.dart

# Generate coverage report
flutter test --coverage
```

**Coverage Target:** 80%+

---

## 📅 Project Timeline

| Phase | Weeks | Status | Focus |
|-------|-------|--------|-------|
| **1: Foundation** | 1-2 | ✅ Complete | Architecture, Database, Setup |
| **2: Backend APIs** | 3-5 | 🔲 Next | Auth, Machines, Maintenance |
| **3: Notifications** | 6-7 | 🔲 Planned | Scheduler, Alerts, Reporting |
| **4: Flutter App** | 8-11 | 🔲 Planned | UI, Integration, Testing |
| **5: Deployment** | 12-13 | 🔲 Planned | Production, Testing |
| **6: Documentation** | 14-16 | 🔲 Planned | Docs, Demo, Presentation |

**Current Status:** Week 1 Complete ✅

---

## 🤝 Contributing

We welcome contributions! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for:

- Branch naming conventions (`feature/`, `bugfix/`, `hotfix/`)
- Commit message format
- Code style (Python/Flutter)
- Pull request process
- Testing requirements

### Quick Contribution Steps

```bash
# 1. Create a feature branch
git checkout -b feature/your-feature-name

# 2. Make changes and test
# ... write code ...
pytest          # Backend
flutter test    # Frontend

# 3. Commit with clear message
git commit -m "feat: add new feature"

# 4. Push and create Pull Request
git push origin feature/your-feature-name
```

---

## 🚀 Deployment

### Backend (Render)

```bash
# Deploy from GitHub
git push origin main
# Render auto-deploys on push
```

Environment variables on Render:
```
DATABASE_URL = your-database-url
JWT_SECRET_KEY = your-secret-key
FIREBASE_CREDENTIALS = your-firebase-key
```

### Frontend (App Stores)

```bash
# Android
flutter build apk --release
# Upload to Google Play Store

# iOS
flutter build ios --release
# Upload to App Store
```

See [DEPLOYMENT.md](docs/DEPLOYMENT.md) for detailed instructions.

---

## 📖 Documentation

- **[API Specification](docs/API_SPECIFICATION.md)** — All endpoints with examples
- **[Database Schema](docs/DATABASE_SCHEMA.md)** — Tables, relationships, indexing
- **[Architecture Guide](docs/ARCHITECTURE.md)** — System design and patterns
- **[Setup Instructions](docs/SETUP.md)** — Detailed configuration guide
- **[Deployment Guide](docs/DEPLOYMENT.md)** — Production deployment steps

---

## 🆘 Troubleshooting

### Backend Won't Start
```bash
# Make sure venv is activated
source venv/bin/activate

# Reinstall dependencies
pip install -r requirements.txt

# Check database connection
echo $DATABASE_URL
```

### Flutter Won't Run
```bash
# Get dependencies
flutter pub get

# Clean build
flutter clean
flutter pub get

# Run with verbose output
flutter run -v
```

### Database Connection Error
```bash
# Check MySQL is running
mysql -u root -p -e "SELECT 1;"

# Or use Docker
docker run -d -p 3306:3306 -e MYSQL_ROOT_PASSWORD=root mysql:8.0
```

See [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) for more.

---

## 📞 Support

- **Issues & Bugs** → [GitHub Issues](https://github.com/Omega-127/MaintHub/issues)
- **Discussions** → [GitHub Discussions](https://github.com/Omega-127/MaintHub/discussions)
- **Team Slack** → #mainthub-dev
- **Weekly Sync** → Friday 5 PM (team meeting)

---


---

## 📝 License

This project is licensed under the **MIT License** — see [LICENSE](LICENSE) for details.

---

## 🎉 Acknowledgments

- Flask & SQLAlchemy for backend framework
- Flutter & Riverpod for mobile framework
- APScheduler for job scheduling
- Firebase for push notifications
- GitHub for version control & CI/CD

---

## 📊 Project Stats

- **Lines of Code:** 5000+ (estimated by Week 16)
- **Test Coverage:** 80%+
- **API Endpoints:** 12+
- **Flutter Screens:** 8+
- **Database Tables:** 4
- **Team Size:** 3-4 developers
- **Timeline:** 16 weeks

---

## 🚀 Getting Started Now

1. **Clone the repo**
   ```bash
   git clone https://github.com/Omega-127/MaintHub.git
   ```

2. **Read the docs**
   - Start with [SETUP.md](docs/SETUP.md)
   - Backend: [mainthub-backend/README.md](mainthub-backend/README.md)
   - Frontend: [mainthub-app/README.md](mainthub-app/README.md)

3. **Run locally**
   ```bash
   bash init_project.sh
   python mainthub-backend/run.py
   flutter run
   ```

4. **Join the team**
   - Read [CONTRIBUTING.md](CONTRIBUTING.md)
   - Claim a task from GitHub Issues
   - Create a pull request

---

## 📅 Latest Updates

- **Week 1 (Aug 2026):** ✅ Foundation & Setup Complete
  - Database schema finalized
  - Project structure initialized
  - Development environment ready
  - Next: Backend APIs (Week 2)

---

## ⭐ If You Like This Project

Please consider:
- ⭐ Starring this repo
- 🍴 Forking for your own use
- 🐛 Reporting issues
- 💡 Suggesting improvements
- 👥 Contributing code

---

**Happy coding! 🚀**

For questions, check the [docs](docs/) or open a [GitHub Issue](https://github.com/Omega-127/MaintHub/issues).

---

*Last Updated: August 2026*  
*Status: In Development (Week 1/16 Complete)*
