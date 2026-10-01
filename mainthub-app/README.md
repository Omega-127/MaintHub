# MaintHub Mobile App (`mainthub-app`)

[![Flutter](https://img.shields.io/badge/Flutter-3.0%2B-blue)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-green)](../LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android-green)](https://developer.android.com/)

The official mobile client for **MaintHub**, an enterprise textile machinery maintenance management system. Built with Flutter, Provider state management, and Dio HTTP client.

---

## 📱 Features

- **Department Scoping & Multi-Tenancy:**
  - **Technicians:** Automatically scoped to their assigned textile department (`BLOWROOM`, `COMBER`, `RING_FRAME`, `SPEED_FRAME`, `WINDING`, `BUFFING`). Shows only relevant equipment, overdue alerts, and service logs.
  - **Administrators:** Global access with real-time department filtering tabs to inspect and manage machinery mill-wide.
- **Real-Time KPIs & Dashboard:**
  - Instant visibility into Total, Active, Inactive, Under Maintenance, Overdue, and Upcoming 7-day machinery.
  - Quick-action widgets for high-priority overdue machines.
- **Searchable & Filterable Machine Registry:**
  - Live search by machine name, type, and location.
  - Visual status pills (`ACTIVE`, `INACTIVE`, `UNDER_MAINTENANCE`, `OVERDUE`).
- **One-Tap Maintenance Logging:**
  - Inspect machinery details, service intervals, and previous service history.
  - Mark maintenance as completed with notes, automatically updating future service schedules.
- **Administrator Capabilities:**
  - Add new machines with custom service intervals and department assignments.
  - Edit machine specifications and status.
- **Secure Authentication & Token Management:**
  - JWT token auto-injection using Dio interceptors.
  - Hardware-backed token encryption via `flutter_secure_storage`.
  - Seamless auto-login check during app boot.

---

## 🏗️ Architecture & Project Structure

The Flutter app follows a clean, layered architecture separating UI, business logic, state management, and network communication:

```
lib/
├── api_client.dart           # Legacy client export
├── main.dart                 # Application entry point & Provider registration
├── config/
│   ├── app_config.dart       # API baseUrl and global config
│   └── theme.dart            # Material 3 colors, typography, button styles
├── models/
│   ├── user.dart             # User model with role & department helper getters
│   ├── machine.dart          # Machine entity with overdue & due-today indicators
│   └── dashboard.dart        # Dashboard metric models & aggregations
├── providers/
│   ├── auth_provider.dart    # Login, signup, token caching, active user session
│   └── machine_provider.dart # Machine listing, department filtering, CRUD state
├── services/
│   ├── api_client.dart       # Dio singleton with JWT token interceptor
│   ├── auth_service.dart     # Authentication REST API connector
│   ├── machine_service.dart  # Machine retrieval and modification endpoints
│   ├── dashboard_service.dart# Metric aggregation endpoints
│   └── machine_services.dart # Service helpers
└── screens/
    ├── splash_screen.dart    # Splash screen route handler
    ├── auth/
    │   └── splash_screen.dart# Token verification and initial routing
    ├── dashboard/
    │   └── dashboard_screen.dart # KPI dashboard implementation
    ├── machines/
    │   ├── login_screen.dart          # Login interface
    │   ├── signup_screen.dart         # Role & department registration interface
    │   ├── dashboard_screen.dart      # Main dashboard with department tabs
    │   ├── machine_list_screen.dart   # Filterable machine list
    │   ├── machine_details_screen.dart# Detailed machine specs & action buttons
    │   └── add_machine_screen.dart    # Admin machinery creation form
    └── maintanance/
        └── pending_screen.dart        # Overdue maintenance action queue
```

---

## ⚙️ Configuration & Environment

The backend URL is configured in `lib/config/app_config.dart`:

```dart
class AppConfig {
  // Option 1: Android Emulator (local PC host)
  static const String baseUrl = 'http://10.0.2.2:5000/api';

  // Option 2: Physical Device (PC's Local Wi-Fi IP)
  // static const String baseUrl = 'http://192.168.1.15:5000/api';

  // Option 3: Production Render Deployment
  // static const String baseUrl = 'https://mainthub-backend.onrender.com/api';

  static const String appName = 'MainHub';
}
```

> 💡 **Important:** Do not use `localhost` when debugging on an Android Emulator or device. Android Emulators map the host machine to `10.0.2.2`.

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK `3.0.0+`
- Android Studio with Android SDK (API 34+ recommended)
- Connected Android Device or Emulator

### Installation & Run

1. **Install packages:**
   ```bash
   flutter pub get
   ```

2. **Verify environment:**
   ```bash
   flutter doctor
   ```

3. **Run on connected device/emulator:**
   ```bash
   flutter run
   ```

---

## 📦 Building Production APK

To build a release APK for Android distribution:

1. Update `lib/config/app_config.dart` to point to your live backend (e.g. `https://mainthub-backend.onrender.com/api`).
2. Run the build command:
   ```bash
   flutter build apk --release
   ```
3. Locate the generated APK at:
   `build/app/outputs/flutter-apk/app-release.apk`

---

## 🧪 Testing

Run Flutter unit and widget tests:

```bash
flutter test
```
