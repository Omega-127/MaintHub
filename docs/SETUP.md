# MaintHub — Local Development Setup Guide

Follow this step-by-step guide to configure and run the full **MaintHub** stack (Backend, Database, and Mobile App) on your local development machine.

---

## 📋 Prerequisites

Before starting, ensure you have the following installed on your workstation:

| Tool | Version Requirement | Purpose |
|------|---------------------|---------|
| **Python** | `3.9+` (tested up to 3.12) | Flask backend service |
| **Flutter SDK** | `3.0.0+` | Cross-platform mobile app |
| **Android Studio** | Latest | Android SDK & Emulator |
| **Docker Desktop** | Latest (Optional but recommended) | Local MySQL & phpMyAdmin |
| **Git** | Latest | Version control |

---

## 🚀 Step 1: Clone Repository

```bash
git clone https://github.com/Omega-127/MaintHub.git
cd MaintHub
```

---

## 🗄️ Step 2: Database Setup

You have two choices for your database:

### Option A: Docker Compose (Recommended)
Docker runs a pre-configured MySQL 8.0 instance and phpMyAdmin with zero manual database creation needed:

```bash
# From repository root
docker-compose up -d mysql phpmyadmin
```

Verify that the container is healthy:
```bash
docker ps
```
- **MySQL Port:** `3306` (User: `mainthub_user`, Password: `mainthub_pass`, Database: `mainthub_db`)
- **phpMyAdmin GUI:** Open `http://localhost:8080` in your web browser.

### Option B: SQLite Auto-Fallback (Quickest for Dev)
If you do not have Docker installed, the backend will automatically fall back to an embedded SQLite database (`instance/mainthub.db`) when MySQL is unreachable on `localhost:3306`. You can skip directly to Step 3.

---

## 🐍 Step 3: Backend Setup (`mainthub-backend`)

### 1. Create Virtual Environment

**On Windows (PowerShell):**
```powershell
cd mainthub-backend
python -m venv venv
.\venv\Scripts\Activate.ps1
```

**On macOS / Linux:**
```bash
cd mainthub-backend
python3 -m venv venv
source venv/bin/activate
```

### 2. Install Dependencies
```bash
pip install --upgrade pip
pip install -r requirements.txt
```

### 3. Configure Environment Variables
Create a `.env` file in `mainthub-backend/` (or copy from `.env.example`):

```env
DATABASE_URL=mysql+pymysql://mainthub_user:mainthub_pass@localhost:3306/mainthub_db
JWT_SECRET_KEY=dev-secret-key-change-in-production-123456
FLASK_ENV=development
PORT=5000
```

> **Note:** If using SQLite fallback, leave `DATABASE_URL` as is; the system will detect port 3306 status and fall back automatically.

### 4. Run the Backend Server
```bash
python run.py
```

The console will indicate that the database tables were inspected, auto-migrated, and 295 machines seeded:
```
* Running on http://127.0.0.1:5000
* Database connected: mysql+pymysql://...
* Auto-migration complete: 295 machines synced.
```

### 5. Verify Backend Health
Open another terminal or browser:
```bash
curl http://localhost:5000/health
# Response: {"status": "ok", "database": "ok"}
```

---

## 📱 Step 4: Mobile App Setup (`mainthub-app`)

### 1. Install Flutter Dependencies
```bash
cd mainthub-app
flutter pub get
```

### 2. Configure Backend URL in `lib/config/app_config.dart`

Depending on your execution target, set the proper `baseUrl`:

```dart
class AppConfig {
  // Option 1: Android Emulator (maps to host localhost)
  static const String baseUrl = 'http://10.0.2.2:5000/api';

  // Option 2: Physical Device on same Wi-Fi (use your PC's LAN IP)
  // static const String baseUrl = 'http://192.168.1.100:5000/api';

  // Option 3: Production Render Backend
  // static const String baseUrl = 'https://mainthub-backend.onrender.com/api';

  static const String appName = 'MainHub';
}
```

### 3. Run the App

Start your Android Emulator or connect your physical Android device with USB debugging enabled, then:

```bash
flutter run
```

---

## 🔑 Default Credentials for Testing

| Role | Email | Password | Scope |
|------|-------|----------|-------|
| **Admin** | `admin@mainthub.com` | `admin123` | Full access across all 6 departments |
| **New Technician** | *Register via Signup Screen* | *Custom* | Scoped to selected department |

---

## 🧪 Step 5: Running Tests

### Backend Tests
```bash
cd mainthub-backend
pytest
```

### Flutter App Tests
```bash
cd mainthub-app
flutter test
```

---

## 🛠️ Common Troubleshooting

### 1. `Execution_Policies` warning on Windows PowerShell
If activating the virtual environment is blocked by script execution policies:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### 2. Android Emulator cannot reach `localhost:5000`
In Android Emulators, `localhost` refers to the emulator itself. Always use `http://10.0.2.2:5000/api` in `app_config.dart`.

### 3. Physical phone cannot connect to backend
Ensure your computer and phone are connected to the same Wi-Fi network, and permit incoming TCP connections on port 5000 through the Windows Firewall.
