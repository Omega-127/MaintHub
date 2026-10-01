# MainHub — Deployment Guide

This guide covers deploying MainHub to production — backend on Render, database on Railway, and Flutter app as an Android APK.

---

## 📋 Table of Contents

- [Architecture Overview](#architecture-overview)
- [Prerequisites](#prerequisites)
- [Database Deployment (Railway)](#database-deployment-railway)
- [Backend Deployment (Render)](#backend-deployment-render)
- [Flutter App Build (Android APK)](#flutter-app-build-android-apk)
- [Environment Variables Reference](#environment-variables-reference)
- [Post-Deployment Checklist](#post-deployment-checklist)
- [Updating a Deployment](#updating-a-deployment)
- [Rollback Procedure](#rollback-procedure)
- [Monitoring & Logs](#monitoring--logs)
- [Troubleshooting](#troubleshooting)

---

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────┐
│            Android Device / Emulator         │
│                Flutter APK                   │
│         mainthub-app (Flutter)               │
└──────────────────┬──────────────────────────┘
                   │ HTTPS
                   │ https://mainthub-backend.onrender.com/api
                   ▼
┌─────────────────────────────────────────────┐
│                  Render                      │
│           Flask Backend (Python)             │
│         mainthub-backend (Flask)             │
└──────────────────┬──────────────────────────┘
                   │ MySQL connection
                   │ (DATABASE_URL)
                   ▼
┌─────────────────────────────────────────────┐
│                 Railway                      │
│             MySQL 8.0 Database               │
│               mainthub_db                   │
└─────────────────────────────────────────────┘
```

**Summary:**
- **Database** → Railway (managed MySQL, free tier available)
- **Backend** → Render (Flask app, auto-deploy from GitHub)
- **Frontend** → Android APK (distributed directly or via Play Store)

---

## ✅ Prerequisites

Before deploying, make sure you have:

- [ ] GitHub account with MainHub repo pushed
- [ ] [Railway](https://railway.app) account (free)
- [ ] [Render](https://render.com) account (free)
- [ ] Android Studio installed (for APK signing)
- [ ] All features tested locally and working
- [ ] `main` branch is stable and up to date

---

## 🗄️ Database Deployment (Railway)

Railway gives you a managed MySQL database in minutes — no server setup required.

### Step 1: Create Railway Project

1. Go to **https://railway.app**
2. Click **"New Project"**
3. Select **"Provision MySQL"**
4. Railway automatically creates a MySQL 8.0 instance

### Step 2: Get Connection Details

Once created, click your MySQL service → **"Variables"** tab. You'll see:

```
MYSQL_URL          → full connection string
MYSQLDATABASE      → mainthub_db (or auto-generated)
MYSQLHOST          → your-host.railway.app
MYSQLPORT          → 3306 (or assigned port)
MYSQLUSER          → root
MYSQLPASSWORD      → auto-generated password
```

Copy the `MYSQL_URL` — you'll need it for Render.

### Step 3: Run the Schema

Connect to your Railway database and run `init.sql`:

**Option A — Railway Query Console:**
1. Click your MySQL service → **"Query"** tab
2. Paste the contents of `init.sql`
3. Click **"Run"**

**Option B — MySQL CLI locally:**
```bash
mysql -h your-host.railway.app \
      -P 3306 \
      -u root \
      -p your-password \
      mainthub_db < init.sql
```

### Step 4: Verify Tables Exist

In Railway Query tab:
```sql
SHOW TABLES;
```

Should output:
```
maintenance_history
machines
notifications
users
```

✅ **Database deployed.**

---

## 🚀 Backend Deployment (Render)

Render auto-deploys your Flask app every time you push to `main`.

### Step 1: Backend Deployment Options on Render

You can deploy the backend using either **Option A (Render Blueprint - Recommended)** or **Option B (Manual Web Service)**.

#### Option A: Render Blueprint (`render.yaml`) — Automated Setup
The repository includes a ready-to-use `render.yaml` blueprint:
1. In Render Dashboard, click **New +** → **Blueprint**.
2. Select the **MaintHub** repository.
3. Render automatically detects `render.yaml` and configures:
   - **Runtime:** Python 3.11
   - **Root Directory:** `mainthub-backend`
   - **Build Command:** `pip install -r requirements.txt`
   - **Start Command:** `gunicorn run:app --bind 0.0.0.0:$PORT`
   - **Health Check Path:** `/health`
4. Set the `DATABASE_URL` environment variable to your Railway connection string.
5. Click **Apply**.

#### Option B: Manual Web Service Setup
1. Go to **https://render.com** → **New +** → **Web Service**
2. Connect your GitHub account and select **MaintHub**
3. Configure the service:

| Setting | Value (Python Runtime) | Value (Docker Runtime) |
|---------|------------------------|------------------------|
| **Name** | `mainthub-backend` | `mainthub-backend` |
| **Region** | Singapore (closest to India) | Singapore |
| **Branch** | `main` | `main` |
| **Root Directory** | `mainthub-backend` | `mainthub-backend` |
| **Runtime** | `Python` | `Docker` |
| **Build Command** | `pip install -r requirements.txt` | *(auto-detected)* |
| **Start Command** | `gunicorn run:app --bind 0.0.0.0:$PORT` | *(auto-detected)* |
| **Health Check Path** | `/health` | `/health` |
| **Instance Type** | `Free` | `Free` |

### Step 2: Set Environment Variables on Render

In your Render service → **Environment** tab → add these variables:

```
DATABASE_URL        = mysql+pymysql://root:PASSWORD@HOST:PORT/mainthub_db
JWT_SECRET_KEY      = generate-a-strong-random-key-min-32-chars
FLASK_ENV           = production
PYTHON_VERSION      = 3.11.11
```

> **Note on DATABASE_URL:** Make sure the URL uses the `mysql+pymysql://` driver prefix. If Railway provides `mysql://...`, change the scheme to `mysql+pymysql://`.
>
> **Generate a strong JWT key:**
> ```bash
> python -c "import secrets; print(secrets.token_hex(32))"
> ```

### Step 3: Trigger First Deploy & Automated Database Boot

Render auto-deploys on push to `main`:

```bash
git checkout main
git merge develop
git push origin main
```

Upon successful startup, the backend automatically runs `_auto_migrate()`:
1. Self-heals database schema (ensures `department` and `is_active` columns exist on `users` and `machines`).
2. Creates the default admin account: `admin@mainthub.com` / `admin123`.
3. Synchronizes all 295 machines across all 6 textile departments (`BLOWROOM`, `COMBER`, `RING_FRAME`, `SPEED_FRAME`, `WINDING`, `BUFFING`).

### Step 4: Verify Backend Health

Once live, Render assigns your service a public URL, for example:
```
https://mainthub-backend.onrender.com
```

Verify your deployment using the `/health` endpoint:
```bash
curl https://mainthub-backend.onrender.com/health
# Response: {"status":"ok","database":"ok"}
```

✅ **Backend deployed and database synchronized.**

---

## 📱 Flutter App Build (Android APK)

### Step 1: Update API URL for Production

Open `mainthub-app/lib/config/app_config.dart` and update:

```dart
class AppConfig {
  // ← Change this to your Render URL before building
  static const String baseUrl = 'https://mainthub-backend.onrender.com/api';
}
```

> ⚠️ **Don't forget this step.** If you leave `10.0.2.2:5000`, the production APK will fail to connect.

### Step 2: Create a Keystore (One Time Only)

A keystore signs your APK — required for Play Store and recommended for all releases.

```bash
keytool -genkey -v \
  -keystore mainthub-release-key.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias mainthub
```

You'll be prompted for:
- Keystore password (remember this!)
- Key password
- Name, org, location details

**Store `mainthub-release-key.jks` safely — losing it means you can never update the app on Play Store.**

### Step 3: Configure Signing in Flutter

Create `mainthub-app/android/key.properties`:

```properties
storePassword=your-keystore-password
keyPassword=your-key-password
keyAlias=mainthub
storeFile=../mainthub-release-key.jks
```

> Add `key.properties` to `.gitignore` — never commit this file.

Edit `mainthub-app/android/app/build.gradle` — add signing config:

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    ...
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

### Step 4: Build the APK

```bash
cd mainthub-app

# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Build release APK
flutter build apk --release
```

Build output location:
```
mainthub-app/build/app/outputs/flutter-apk/app-release.apk
```

### Step 5: Test the APK

Install directly on a physical Android device:

```bash
# Via USB (device must have USB debugging enabled)
flutter install --release

# Or copy APK to device manually and install
adb install build/app/outputs/flutter-apk/app-release.apk
```

### Step 6: Distribute the APK

**Option A: Direct distribution (easiest for college project)**
- Share `app-release.apk` via WhatsApp, Google Drive, or email
- Recipients: Settings → Install unknown apps → Allow

**Option B: Google Play Store (industry-level)**
1. Create Google Play Developer account ($25 one-time fee)
2. Go to Play Console → Create app
3. Upload APK under **"Production"** track
4. Fill in store listing details
5. Submit for review (takes 3-7 days)

✅ **Flutter app built and ready.**

---

## 🔑 Environment Variables Reference

### Backend (.env / Render Dashboard)

| Variable | Example | Required | Notes |
|----------|---------|----------|-------|
| `DATABASE_URL` | `mysql+pymysql://user:pass@host:port/db` | ✅ | From Railway |
| `JWT_SECRET_KEY` | `a3f8b2c1...` (32+ chars) | ✅ | Generate randomly |
| `FLASK_ENV` | `production` | ✅ | Never `development` in prod |
| `PORT` | `5000` | Auto-set by Render | Don't override |

### Flutter (app_config.dart)

| Variable | Development | Production |
|----------|-------------|-----------|
| `baseUrl` | `http://10.0.2.2:5000/api` | `https://mainthub-backend.onrender.com/api` |

---

## ✅ Post-Deployment Checklist

Run through this after every deployment:

### Database
- [ ] All 4 tables exist (`SHOW TABLES`)
- [ ] Seed admin account exists (`SELECT * FROM users`)
- [ ] Can connect from Railway Query console

### Backend
- [ ] Render deploy shows "Live"
- [ ] `GET /api/machines/` returns `[]` (not an error)
- [ ] `POST /api/auth/login` returns a token
- [ ] Scheduler started (check Render logs for `[Scheduler] Started`)

### Flutter App
- [ ] APK installs on device without errors
- [ ] Splash screen loads and transitions to login
- [ ] Login works with `admin@mainthub.com` / `admin123`
- [ ] Dashboard loads KPI cards
- [ ] Can add a machine (admin)
- [ ] Can mark maintenance complete (technician)

---

## 🔄 Updating a Deployment

### Backend Update

Every push to `main` triggers an auto-deploy on Render.

```bash
# Merge your changes into main
git checkout main
git merge develop
git push origin main

# Render auto-deploys — watch logs at render.com
```

### Database Schema Change

If you add/modify tables:

```bash
# Connect to Railway MySQL
mysql -h host.railway.app -u root -p mainthub_db

# Run your ALTER TABLE or new CREATE TABLE
ALTER TABLE machines ADD COLUMN notes TEXT;
```

> ⚠️ **Never drop columns or tables without a backup.** Always add, never remove in production.

### Flutter App Update

```bash
# Bump version in pubspec.yaml first
# version: 1.0.1+2  ← increment both numbers

cd mainthub-app
flutter build apk --release

# Redistribute the new APK
```

---

## ⏪ Rollback Procedure

If something breaks after a deploy:

### Backend Rollback (Render)

1. Go to Render dashboard → your service
2. Click **"Deploys"** tab
3. Find the last working deploy
4. Click **"Redeploy"** on that version

### Database Rollback

Railway doesn't auto-backup on free tier. Best practice:

```bash
# Before any schema change, take a backup:
mysqldump -h host.railway.app \
          -u root -p \
          mainthub_db > backup_$(date +%Y%m%d).sql

# To restore:
mysql -h host.railway.app -u root -p mainthub_db < backup_20260801.sql
```

### Flutter Rollback

Redistribute the previous APK file. Keep all release APKs stored in a shared Google Drive folder labeled by version.

---

## 📊 Monitoring & Logs

### Backend Logs (Render)

1. Go to **render.com** → your service
2. Click **"Logs"** tab
3. Watch real-time output

Key things to watch:
```
[Scheduler] Started — daily check at 6:00 AM   ← scheduler running
 * Running on http://0.0.0.0:5000              ← server up
ERROR ...                                       ← investigate immediately
```

### Database Monitoring (Railway)

1. Go to **railway.app** → your project
2. Click MySQL service → **"Metrics"** tab
3. Monitor: CPU, Memory, Connections, Storage

### Health Check Endpoint

Add this to your backend to verify it's alive:

```python
# In app/routes/auth.py or a new health.py
@app.route('/health')
def health():
    return {'status': 'ok'}, 200
```

Test anytime:
```bash
curl https://mainthub-backend.onrender.com/health
# {"status": "ok"}
```

---

## 🆘 Troubleshooting

### Backend Won't Deploy on Render

```
Problem: Build failed
Check:   Render logs for exact error

Common causes:
- requirements.txt has a package that won't install
  → Check package names and versions
- Dockerfile has wrong path
  → Verify root directory is set to mainthub-backend
- Missing environment variable
  → Check all required vars are set in Render dashboard
```

### Database Connection Error

```
Problem: sqlalchemy.exc.OperationalError — Can't connect to MySQL
Check:   DATABASE_URL in Render environment variables

Common causes:
- Wrong host/port from Railway
  → Copy DATABASE_URL exactly from Railway variables tab
- Railway MySQL not running
  → Check Railway dashboard for service status
- Wrong format
  → Must be: mysql+pymysql://user:pass@host:port/dbname
```

### Flutter APK Won't Connect to Backend

```
Problem: Network error / timeout in app
Check:   app_config.dart baseUrl

Common causes:
- Still pointing to localhost (10.0.2.2)
  → Change to https://mainthub-backend.onrender.com/api
- HTTPS vs HTTP mismatch
  → Render uses HTTPS — make sure URL starts with https://
- Render free tier sleeping
  → Free tier sleeps after 15 mins inactivity
  → First request takes 30-60 seconds to wake up
  → Solution: Upgrade to paid tier for production
```

### Render Free Tier Sleeping

Render free tier spins down after 15 minutes of inactivity. First request after sleep takes 30-60 seconds.

**Fix for college project:** Acceptable — just warn users about initial load time.

**Fix for production:** Upgrade to Render Starter ($7/month) which keeps the service always on.

---

## 📁 Files to Never Commit

```
.env                         ← real credentials
mainthub-release-key.jks     ← signing keystore
key.properties               ← keystore passwords
firebase-credentials.json    ← Firebase service account
google-services.json         ← Firebase Android config
```

All of these are in `.gitignore`. Double-check before every push:

```bash
git status
# None of the above files should appear
```

---

## 📞 Deployment Support

| Issue | Where to Look |
|-------|--------------|
| Backend deploy fails | Render → Logs tab |
| Database connection | Railway → Variables tab |
| Flutter build error | Terminal output |
| APK install fails | Android → Settings → Unknown sources |
| General | Team chat or GitHub Issues |

---

## 🔗 Quick Links

| Service | URL |
|---------|-----|
| GitHub Repo | https://github.com/Omega-127/MaintHub |
| Render Dashboard | https://render.com/dashboard |
| Railway Dashboard | https://railway.app/dashboard |
| Backend (Live) | https://mainthub-backend.onrender.com |
| Backend Health | https://mainthub-backend.onrender.com/health |

---

*Last updated: August 2026*
*MainHub Team*
