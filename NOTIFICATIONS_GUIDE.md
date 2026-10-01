# MaintHub — In-App Notifications & Scheduling Guide

MaintHub features an automated background notification and scheduling engine that alerts technicians and maintenance administrators when machinery is due or overdue for servicing across all 6 textile mill departments.

---

## 🔔 How Notifications Work

### 1. Automatic Scheduler Evaluation (Backend)

Every day at **6:00 AM**, `APScheduler` runs an automated inspection in `app/services/scheduler.py`:

```
1. Query active machines where: next_maintenance_date <= TODAY()
2. For each due machine:
   - If next_maintenance_date < TODAY() → Mark as OVERDUE (⚠️)
   - If next_maintenance_date == TODAY() → Mark as REMINDER (🔔)
3. For each active Technician and Admin:
   - Check if an unread notification already exists for machine + user
   - If not, create and persist a new notification row in the database
4. Log results to server output
```

### 2. Concrete Example

**Machine:** `RF-14 Ring Frame`  
**Department:** `RING_FRAME`  
**Location:** Shed 2, Line B  
**Next Maintenance:** `2026-09-25`  
**Today's Date:** `2026-10-01`  

→ Evaluation: **OVERDUE** (by 6 days)

→ Notification record created in MySQL:
```json
{
  "id": 42,
  "machine_id": 14,
  "user_id": 3,
  "title": "⚠️ OVERDUE: RF-14 Ring Frame",
  "message": "Machine 'RF-14 Ring Frame' (Ring Frame) at Shed 2, Line B was due on 2026-09-25.",
  "notification_type": "OVERDUE",
  "is_sent": true,
  "is_read": false,
  "created_at": "2026-10-01T06:00:00"
}
```

---

## 📱 Mobile App Presentation

### Notification Classifications

| Type | Badge / Icon | Indicator Color | Condition |
|------|--------------|-----------------|-----------|
| **REMINDER** | 🔔 Due Today | Amber / Blue | `next_maintenance_date == TODAY()` |
| **OVERDUE** | ⚠️ Overdue | Crimson Red | `next_maintenance_date < TODAY()` |
| **COMPLETED** | ✅ Completed | Green | Triggered when technician marks machine complete |

### User Interface Views

1. **Dashboard KPI Banner & Overdue Carousel:**
   - Highlights the top 5 most critical overdue machines with direct navigation to machine detail.
2. **Pending Maintenance Screen (`lib/screens/maintanance/pending_screen.dart`):**
   - Displays all overdue and due machines filtered by the user's assigned department.
   - Includes a quick **"Mark Complete"** button to log service on the spot.
3. **Machine Details Screen (`lib/screens/machines/machine_details_screen.dart`):**
   - Shows maintenance schedule badges, previous service notes, and technician logs.

---

## 🔄 Lifecycle Workflow

```
Admin registers equipment:
  Machine: AC-12 Autoconer
  Department: WINDING
  Interval: 30 days
  First maintenance: 2026-10-01
  ↓
Backend automatically sets:
  next_maintenance_date = 2026-10-01 + 30 days = 2026-10-31
  ↓
At 6:00 AM on 2026-10-31:
  APScheduler evaluates AC-12 Autoconer as due today
  ↓
Dispatches notification to Winding technicians:
  Title: "🔔 Due Today: AC-12 Autoconer"
  ↓
Technician opens MaintHub app:
  Views alert on Dashboard & Pending screen
  Performs service and taps "Mark Complete"
  Adds optional service notes (e.g. "Replaced tension discs")
  ↓
Backend processes completion:
  Logs audit record in maintenance_history
  Sets last_maintenance_date = 2026-10-31
  Calculates next_maintenance_date = 2026-10-31 + 30 = 2026-11-30
  Status resets to ACTIVE
  ↓
Cycle repeats automatically in 30 days
```

---

## 🛠️ Backend Scheduler Implementation

**File:** `mainthub-backend/app/services/scheduler.py`

```python
from apscheduler.schedulers.background import BackgroundScheduler
from datetime import date, datetime, timezone

def check_due_machines(app):
    with app.app_context():
        from app import db
        from app.models.machine import Machine
        from app.models.notification import Notification
        from app.models.user import User

        today = date.today()
        due_machines = Machine.query.filter(
            Machine.next_maintenance_date <= today,
            Machine.status == "ACTIVE"
        ).all()

        if not due_machines:
            return

        technicians = User.query.filter(
            User.role.in_(["TECHNICIAN", "ADMIN"]),
            User.is_active == True
        ).all()

        for machine in due_machines:
            is_overdue = machine.next_maintenance_date < today
            notif_type = "OVERDUE" if is_overdue else "REMINDER"
            title = f"{'⚠️ OVERDUE' if is_overdue else '🔔 Due Today'}: {machine.name}"
            message = (
                f"Machine '{machine.name}' ({machine.type}) at {machine.location or 'N/A'} "
                f"{'was due on' if is_overdue else 'is due for'} maintenance "
                f"on {machine.next_maintenance_date}."
            )

            for tech in technicians:
                # Prevent duplicate alerts for the same machine and user
                existing = Notification.query.filter_by(
                    machine_id=machine.id,
                    user_id=tech.id,
                    is_sent=False
                ).first()

                if not existing:
                    notif = Notification(
                        machine_id=machine.id,
                        user_id=tech.id,
                        title=title,
                        message=message,
                        notification_type=notif_type,
                        is_sent=True,
                        sent_at=datetime.now(timezone.utc)
                    )
                    db.session.add(notif)

        db.session.commit()

def start_scheduler(app):
    scheduler = BackgroundScheduler()
    scheduler.add_job(
        func=lambda: check_due_machines(app),
        trigger="cron",
        hour=6,
        minute=0,
        id="daily_maintenance_check",
        replace_existing=True
    )
    scheduler.start()
    return scheduler
```

---

## 🔌 API Endpoints for Notifications

### 1. List User's Notifications
- **Method / URL:** `GET /api/notifications/`
- **Header:** `Authorization: Bearer <jwt_token>`

#### Response (`200 OK`)
```json
[
  {
    "id": 12,
    "machine_id": 5,
    "title": "⚠️ OVERDUE: B-02 Bale Opener",
    "message": "Machine 'B-02 Bale Opener' (Bale Opener) at Shed 1 was due on 2026-09-28.",
    "notification_type": "OVERDUE",
    "is_read": false,
    "created_at": "2026-10-01 06:00:00"
  }
]
```

### 2. Acknowledge Notification
- **Method / URL:** `PUT /api/notifications/<id>/read`
- **Header:** `Authorization: Bearer <jwt_token>`

#### Response (`200 OK`)
```json
{
  "message": "Notification marked as read"
}
```

---

## ⚙️ Customizing the Scheduler

### Modifying Job Execution Time
To alter the scheduler trigger time (for instance, to 8:30 AM), adjust `app/services/scheduler.py`:

```python
scheduler.add_job(
    func=lambda: check_due_machines(app),
    trigger="cron",
    hour=8,
    minute=30,
    id="daily_maintenance_check",
    replace_existing=True
)
```

### Disabling Alerts for Out-of-Service Equipment
Set the machine status to `INACTIVE`:
```sql
UPDATE machines SET status = 'INACTIVE' WHERE id = 14;
```
The scheduler automatically ignores machines that are not `ACTIVE`.

---

## 🧪 Testing the Notification Flow

### Test Manually via Backend Terminal
You can run an immediate evaluation in Python without waiting until 6:00 AM:

```bash
cd mainthub-backend
python -c "from app import create_app; from app.services.scheduler import check_due_machines; app = create_app(); check_due_machines(app)"
```

### Check Database Records
```sql
SELECT 
    n.id, 
    m.name AS machine_name, 
    u.full_name AS recipient, 
    n.title, 
    n.notification_type, 
    n.created_at
FROM notifications n
JOIN machines m ON n.machine_id = m.id
JOIN users u ON n.user_id = u.id
ORDER BY n.created_at DESC 
LIMIT 10;
```
