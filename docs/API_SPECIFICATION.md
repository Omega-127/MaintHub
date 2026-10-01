# MaintHub — API Specification

Welcome to the REST API documentation for **MaintHub**, a machine maintenance management system.

- **Base URL (Production):** `https://mainthub-backend.onrender.com/api`
- **Base URL (Local Development):** `http://localhost:5000/api` (or `http://10.0.2.2:5000/api` for Android Emulator)
- **Content-Type:** `application/json`
- **Authentication:** Bearer token in the `Authorization` header (`Authorization: Bearer <token>`)

---

## 📋 Table of Contents
1. [Authentication Endpoints](#1-authentication-endpoints)
2. [Machine Management Endpoints](#2-machine-management-endpoints)
3. [Maintenance Endpoints](#3-maintenance-endpoints)
4. [Dashboard Endpoints](#4-dashboard-endpoints)
5. [Notification Endpoints](#5-notification-endpoints)
6. [System & Health Endpoints](#6-system--health-endpoints)
7. [Error Handling & Status Codes](#7-error-handling--status-codes)

---

## 1. Authentication Endpoints

### 1.1 Register User
Register a new user account. Technicians must provide an assigned department, while Admins oversee all departments.

- **Method / URL:** `POST /api/auth/register`
- **Auth Required:** No

#### Request Body
```json
{
  "full_name": "Rajesh Kumar",
  "email": "rajesh@mainthub.com",
  "password": "securepassword123",
  "role": "TECHNICIAN",
  "department": "RING_FRAME"
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `full_name` | string | Yes | User's full display name |
| `email` | string | Yes | Unique valid email address (case-insensitive) |
| `password` | string | Yes | User password |
| `role` | string | Yes | Either `"ADMIN"` or `"TECHNICIAN"` |
| `department` | string | Conditional | Required for `TECHNICIAN`. Must be one of: `"BLOWROOM"`, `"COMBER"`, `"RING_FRAME"`, `"SPEED_FRAME"`, `"WINDING"`, `"BUFFING"`. Must be `null` or omitted for `ADMIN`. |

#### Response (`201 Created`)
```json
{
  "message": "User registered successfully",
  "access_token": "eyJhbGciOiJIUzI1NiIsIn...",
  "user": {
    "id": 2,
    "full_name": "Rajesh Kumar",
    "email": "rajesh@mainthub.com",
    "role": "TECHNICIAN",
    "department": "RING_FRAME"
  }
}
```

---

### 1.2 User Login
Authenticate with email and password to receive a JWT access token.

- **Method / URL:** `POST /api/auth/login`
- **Auth Required:** No

#### Request Body
```json
{
  "email": "admin@mainthub.com",
  "password": "admin123"
}
```

#### Response (`200 OK`)
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsIn...",
  "user": {
    "id": 1,
    "full_name": "Admin User",
    "email": "admin@mainthub.com",
    "role": "ADMIN",
    "department": null
  }
}
```

---

### 1.3 Get Current User Profile
Fetch details of the currently authenticated user.

- **Method / URL:** `GET /api/auth/me`
- **Auth Required:** Yes (`Bearer <token>`)

#### Response (`200 OK`)
```json
{
  "id": 1,
  "full_name": "Admin User",
  "email": "admin@mainthub.com",
  "role": "ADMIN",
  "department": null
}
```

---

## 2. Machine Management Endpoints

### 2.1 List All Machines
Retrieve list of machines. Technicians receive only machines belonging to their assigned department. Admins see all machines or can filter via query parameter.

- **Method / URL:** `GET /api/machines/`
- **Auth Required:** Yes (`Bearer <token>`)
- **Query Parameters (Admin only):**
  - `department` (optional): Filter by department (`BLOWROOM`, `COMBER`, `RING_FRAME`, `SPEED_FRAME`, `WINDING`, `BUFFING`).

#### Response (`200 OK`)
```json
[
  {
    "id": 1,
    "name": "B-01 Bale Opener",
    "type": "Bale Opener",
    "department": "BLOWROOM",
    "location": "Shed 1, Line A",
    "maintenance_interval": 30,
    "last_maintenance_date": "2026-09-01",
    "next_maintenance_date": "2026-10-01",
    "status": "ACTIVE",
    "created_by": 1
  }
]
```

---

### 2.2 Get Machine Types
Returns distinct machine types currently available in the database (e.g. Bale Opener, Carding, Ring Frame, Autoconer).

- **Method / URL:** `GET /api/machines/types`
- **Auth Required:** Yes (`Bearer <token>`)

#### Response (`200 OK`)
```json
[
  "Autoconer",
  "Bale Opener",
  "Buffing Machine",
  "Carding",
  "Comber",
  "Draw Frame",
  "Lap Former",
  "Ring Frame",
  "Roving / Speed Frame"
]
```

---

### 2.3 Get Departments
Returns the 6 supported textile mill departments.

- **Method / URL:** `GET /api/machines/departments`
- **Auth Required:** Yes (`Bearer <token>`)

#### Response (`200 OK`)
```json
[
  "BLOWROOM",
  "COMBER",
  "RING_FRAME",
  "SPEED_FRAME",
  "WINDING",
  "BUFFING"
]
```

---

### 2.4 Get Due / Overdue Machines
Returns active machines where `next_maintenance_date <= today`, sorted ascending with `days_overdue`. Scoped by user department for technicians.

- **Method / URL:** `GET /api/machines/due`
- **Auth Required:** Yes (`Bearer <token>`)

#### Response (`200 OK`)
```json
[
  {
    "id": 4,
    "name": "RF-12 Ring Frame",
    "type": "Ring Frame",
    "department": "RING_FRAME",
    "location": "Shed 2, Section C",
    "maintenance_interval": 15,
    "last_maintenance_date": "2026-09-10",
    "next_maintenance_date": "2026-09-25",
    "status": "ACTIVE",
    "created_by": 1,
    "days_overdue": 6
  }
]
```

---

### 2.5 Get Machine by ID
Fetch complete details of a single machine.

- **Method / URL:** `GET /api/machines/<id>`
- **Auth Required:** Yes (`Bearer <token>`)

#### Response (`200 OK`)
```json
{
  "id": 1,
  "name": "B-01 Bale Opener",
  "type": "Bale Opener",
  "department": "BLOWROOM",
  "location": "Shed 1, Line A",
  "maintenance_interval": 30,
  "last_maintenance_date": "2026-09-01",
  "next_maintenance_date": "2026-10-01",
  "status": "ACTIVE",
  "created_by": 1
}
```

---

### 2.6 Create Machine
Create a new machine. Calculates initial `next_maintenance_date` automatically from `first_maintenance_date + maintenance_interval`.

- **Method / URL:** `POST /api/machines/`
- **Auth Required:** Yes (Role: `ADMIN`)

#### Request Body
```json
{
  "name": "SF-08 Speed Frame",
  "type": "Speed Frame",
  "department": "SPEED_FRAME",
  "location": "Shed 2, Bay 4",
  "maintenance_interval": 30,
  "first_maintenance_date": "2026-10-01"
}
```

#### Response (`201 Created`)
```json
{
  "message": "Machine created successfully",
  "id": 296,
  "name": "SF-08 Speed Frame",
  "department": "SPEED_FRAME",
  "next_maintenance_date": "2026-10-31"
}
```

---

### 2.7 Update Machine
Update machine attributes. If `maintenance_interval` is changed and `last_maintenance_date` exists, `next_maintenance_date` recalculates automatically.

- **Method / URL:** `PUT /api/machines/<id>`
- **Auth Required:** Yes (Role: `ADMIN`)

#### Request Body
```json
{
  "name": "SF-08 Speed Frame (Overhauled)",
  "status": "ACTIVE",
  "maintenance_interval": 45
}
```

#### Response (`200 OK`)
```json
{
  "message": "Machine updated successfully"
}
```

---

### 2.8 Delete Machine
Delete a machine and its associated maintenance records and notifications.

- **Method / URL:** `DELETE /api/machines/<id>`
- **Auth Required:** Yes (Role: `ADMIN`)

#### Response (`200 OK`)
```json
{
  "message": "Machine deleted successfully"
}
```

---

## 3. Maintenance Endpoints

### 3.1 Mark Maintenance as Complete
Records a maintenance log entry, updates `last_maintenance_date` to today, recalculates `next_maintenance_date` (`today + maintenance_interval`), and sets status to `ACTIVE`.

- **Method / URL:** `POST /api/maintenance/<machine_id>/complete`
- **Auth Required:** Yes (`Bearer <token>`)

#### Request Body (Optional notes)
```json
{
  "notes": "Lubricated bearings, inspected roller pressure and belt alignment."
}
```

#### Response (`200 OK`)
```json
{
  "message": "Maintenance marked as complete",
  "next_maintenance_date": "2026-10-31"
}
```

---

### 3.2 Get Machine Maintenance History
Retrieve all past maintenance activities for a specific machine in reverse chronological order.

- **Method / URL:** `GET /api/maintenance/<machine_id>/history`
- **Auth Required:** Yes (`Bearer <token>`)

#### Response (`200 OK`)
```json
[
  {
    "id": 14,
    "maintenance_date": "2026-10-01 10:30:00",
    "status": "COMPLETED",
    "notes": "Lubricated bearings, inspected roller pressure.",
    "technician_id": 2
  }
]
```

---

### 3.3 Get Due Machines (Maintenance Service)
Alternative route for querying active machines that are currently due or overdue.

- **Method / URL:** `GET /api/maintenance/due`
- **Auth Required:** Yes (`Bearer <token>`)

---

### 3.4 Get Global Maintenance History
Retrieve latest maintenance history across all machines.

- **Method / URL:** `GET /api/maintenance/history?limit=20`
- **Auth Required:** Yes (`Bearer <token>`)

---

## 4. Dashboard Endpoints

### 4.1 Get Dashboard KPIs & Overdue Machines
Provides key performance indicators, top 5 overdue machines for quick actions, and recent maintenance logs. Automatically filters to technician's assigned department; admins can pass `?department=`.

- **Method / URL:** `GET /api/dashboard/`
- **Auth Required:** Yes (`Bearer <token>`)
- **Query Parameters (Admin only):**
  - `department` (optional): `"BLOWROOM" | "COMBER" | "RING_FRAME" | "SPEED_FRAME" | "WINDING" | "BUFFING"`

#### Response (`200 OK`)
```json
{
  "summary": {
    "total_machines": 295,
    "active": 295,
    "inactive": 0,
    "under_maintenance": 0,
    "overdue": 12,
    "upcoming_7_days": 28
  },
  "overdue_machines": [
    {
      "id": 34,
      "name": "RF-10 Ring Frame",
      "type": "Ring Frame",
      "department": "RING_FRAME",
      "location": "Shed 2, Row 3",
      "next_maintenance_date": "2026-09-22",
      "days_overdue": 9
    }
  ],
  "recent_maintenance": [
    {
      "id": 10,
      "machine_id": 1,
      "machine_name": "B-01 Bale Opener",
      "technician_id": 2,
      "technician_name": "Rajesh Kumar",
      "maintenance_date": "2026-10-01 09:15:00",
      "status": "COMPLETED"
    }
  ]
}
```

---

## 5. Notification Endpoints

### 5.1 Get User Notifications
Fetch in-app notifications generated for the current user (e.g. reminders, overdue alerts).

- **Method / URL:** `GET /api/notifications/`
- **Auth Required:** Yes (`Bearer <token>`)

#### Response (`200 OK`)
```json
[
  {
    "id": 5,
    "machine_id": 34,
    "title": "⚠️ OVERDUE: RF-10 Ring Frame",
    "message": "RF-10 Ring Frame (Ring Frame) was due on 22 Sep 2026.",
    "notification_type": "OVERDUE",
    "is_read": false,
    "created_at": "2026-10-01 06:00:00"
  }
]
```

---

### 5.2 Mark Notification as Read
Marks a specific notification as read.

- **Method / URL:** `PUT /api/notifications/<id>/read`
- **Auth Required:** Yes (`Bearer <token>`)

#### Response (`200 OK`)
```json
{
  "message": "Notification marked as read"
}
```

---

## 6. System & Health Endpoints

### 6.1 Backend & Database Health Check
Unauthenticated health check endpoint used by uptime monitors, load balancers, and Render liveness probes.

- **Method / URL:** `GET /health` or `GET /api/health`
- **Auth Required:** No

#### Response (`200 OK`)
```json
{
  "status": "ok",
  "database": "ok"
}
```

#### Error Response (`500 Internal Server Error`)
```json
{
  "status": "ok",
  "database": "error",
  "database_error": "Connection timed out"
}
```

---

## 7. Error Handling & Status Codes

All errors return JSON with an `error` key:

```json
{
  "error": "Error message description"
}
```

| HTTP Status | Meaning | Common Reasons |
|-------------|---------|----------------|
| `200 OK` | Request succeeded | Fetching data, updates |
| `201 Created` | Resource created | Registration, adding machine |
| `400 Bad Request` | Missing or invalid parameters | Invalid email, missing required fields, invalid date format |
| `401 Unauthorized` | Invalid or expired credentials | Missing/invalid JWT token, wrong password |
| `403 Forbidden` | Access denied | Non-admin attempting admin-only endpoint |
| `404 Not Found` | Resource not found | Machine or user ID does not exist |
| `409 Conflict` | Conflict with existing state | Email already registered |
| `500 Internal Error` | Server or database exception | DB connection dropped, unhandled crash |
