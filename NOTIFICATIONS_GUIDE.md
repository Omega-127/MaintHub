# MainHub — In-App Notifications Guide

MainHub has a built-in notification system that automatically alerts technicians when maintenance is due. No emails — everything happens in the app.

---

## 🔔 How Notifications Work

### Automatic Generation (Backend)

Every day at **6:00 AM**, APScheduler runs this process:

```
1. Query all machines with: next_maintenance_date <= TODAY()
2. For each due machine:
   - Determine type: REMINDER (due today) or OVERDUE (past due)
   - Create notification for ALL technicians
   - Save to database
3. Log the process
```

### Example

**Machine:** Pump-001  
**Next Maintenance:** 2026-08-09  
**Today:** 2026-08-10

→ Status: **OVERDUE**

→ Notification created:
```json
{
  "machine_id": 1,
  "user_id": 2,  // technician
  "title": "⚠️ OVERDUE: Pump-001",
  "message": "Pump-001 (Pump) at Hall A was due on 09 Aug 2026.",
  "notification_type": "OVERDUE",
  "is_sent": true,
  "is_read": false
}
```

---

## 📱 Frontend Display

### Notification Types

| Type | Icon | Color | When |
|------|------|-------|------|
| REMINDER | 🔔 | Blue | Due today |
| OVERDUE | ⚠️ | Red | Past due date |
| COMPLETED | ✅ | Green | Maintenance done |

### User Views

**1. Pending Maintenance Screen**
```
Shows only OVERDUE machines
- Pump-001 (⚠️ OVERDUE)
- Motor-B (⚠️ OVERDUE)
- Loom-C (⚠️ OVERDUE)
```

**2. Notifications List** (future implementation)
```
All notifications for user
- ⚠️ OVERDUE: Pump-001 — 09 Aug 2026
- 🔔 REMINDER: Motor-B — today
- ✅ COMPLETED: Loom-C — yesterday
```

**3. Machine Detail Screen**
```
View machine + "Mark Complete" button
→ Tap to mark done
→ Creates COMPLETED notification for all users
→ Recalculates next maintenance date
```

---

## 🔄 The Full Workflow

```
Admin adds machine:
  Name: Pump-001
  Type: Pump
  Interval: 90 days
  First maintenance: 2026-08-01
  ↓
Backend calculates:
  next_maintenance_date = 2026-08-01 + 90 = 2026-10-30
  ↓
6:00 AM on 2026-10-30:
  APScheduler finds Pump-001 is due
  ↓
Creates notification:
  Title: "🔔 Due Today: Pump-001"
  For: All technicians
  ↓
Technician opens app:
  Sees notification in Pending list
  Taps "Mark Complete"
  ↓
Backend:
  Creates COMPLETED notification
  Updates: last_maintenance_date = 2026-10-30
  Recalculates: next_maintenance_date = 2026-10-30 + 90 = 2026-12-28
  ↓
Cycle repeats in 90 days
```

---

## 🛠️ Backend Implementation

### Scheduler Code

**File:** `app/services/scheduler.py`

```python
def check_due_machines(app):
    """Runs daily at 6 AM"""
    with app.app_context():
        # Find all active machines due today or overdue
        due_machines = Machine.query.filter(
            Machine.next_maintenance_date <= today,
            Machine.status == "ACTIVE"
        ).all()

        # Get all technicians to notify
        technicians = User.query.filter_by(
            role="TECHNICIAN",
            is_active=True
        ).all()

        # Create notifications for each technician
        for machine in due_machines:
            is_overdue = machine.next_maintenance_date < today
            notif_type = "OVERDUE" if is_overdue else "REMINDER"
            
            for tech in technicians:
                notif = Notification(
                    machine_id=machine.id,
                    user_id=tech.id,
                    title=f"{'⚠️ OVERDUE' if is_overdue else '🔔 Due Today'}: {machine.name}",
                    message=f"Machine '{machine.name}' is due for maintenance.",
                    notification_type=notif_type,
                    is_sent=True,
                    sent_at=datetime.now(timezone.utc)
                )
                db.session.add(notif)
        
        db.session.commit()
```

### API Endpoints

**Get User's Notifications**
```
GET /api/notifications/
Authorization: Bearer {token}

Response:
[
  {
    "id": 1,
    "machine_id": 1,
    "title": "⚠️ OVERDUE: Pump-001",
    "message": "Pump-001 (Pump) at Hall A was due on 09 Aug 2026.",
    "notification_type": "OVERDUE",
    "is_read": false,
    "created_at": "2026-08-10T06:00:00"
  },
  ...
]
```

**Mark Notification as Read**
```
PUT /api/notifications/{id}/read
Authorization: Bearer {token}

Response:
{
  "message": "Notification marked as read"
}
```

---

## 📱 Frontend Implementation

### Fetching Notifications

**File:** `lib/services/notification_service.dart`

```dart
class NotificationService {
  Future<List<Notification>> getNotifications() async {
    final response = await _client.get('/notifications/');
    return (response.data as List)
        .map((json) => Notification.fromJson(json))
        .toList();
  }

  Future<void> markAsRead(int notifId) async {
    await _client.put('/notifications/$notifId/read');
  }
}
```

### Display in UI

**File:** `lib/screens/maintenance/pending_screen.dart`

```dart
// Shows overdue machines as notifications
ListView.builder(
  itemCount: overdueMachines.length,
  itemBuilder: (_, i) {
    final machine = overdueMachines[i];
    return Card(
      child: ListTile(
        leading: Icon(Icons.warning_rounded, color: Colors.red),
        title: Text(machine.name),
        subtitle: Text('Due: ${machine.nextMaintenanceDate}'),
        trailing: ElevatedButton(
          onPressed: () => markComplete(machine.id),
          child: Text('Mark Complete'),
        ),
      ),
    );
  },
)
```

---

## 🔧 Configuration

### Change Scheduler Time

Edit `app/services/scheduler.py`:

```python
scheduler.add_job(
    func=lambda: check_due_machines(app),
    trigger="cron",
    hour=6,           # ← Change this
    minute=0,         # ← Or this
    id="daily_maintenance_check",
    replace_existing=True
)
```

Examples:
- `hour=6, minute=0` → 6:00 AM (default)
- `hour=8, minute=30` → 8:30 AM
- `hour=14, minute=0` → 2:00 PM

### Disable Notifications for a Machine

```python
# Set machine status to INACTIVE
machine.status = "INACTIVE"
db.session.commit()
# Scheduler will skip it
```

---

## 📊 Notification Database Structure

**Table:** `notifications`

| Column | Type | Purpose |
|--------|------|---------|
| `id` | INT | Primary key |
| `machine_id` | INT | Which machine (FK) |
| `user_id` | INT | Which technician (FK) |
| `title` | VARCHAR | Short alert title |
| `message` | TEXT | Full message |
| `notification_type` | ENUM | REMINDER, OVERDUE, COMPLETED |
| `is_sent` | BOOLEAN | Was it sent/created? |
| `is_read` | BOOLEAN | Did user see it? |
| `sent_at` | DATETIME | When it was created |
| `created_at` | DATETIME | Timestamp |

---

## 🧪 Testing Notifications

### Manual Test (Backend)

```bash
# Connect to your MySQL
mysql -h localhost -u root mainthub_db

# Check for notifications created today
SELECT * FROM notifications WHERE DATE(created_at) = CURDATE();

# Check for overdue machines
SELECT * FROM machines 
WHERE next_maintenance_date < CURDATE() 
AND status = 'ACTIVE';
```

### Manual Test (Frontend)

1. Start the app
2. Dashboard → "Pending Maintenance"
3. If no overdue machines show, add one manually:
   - Admin → Add Machine → set `next_maintenance_date` to yesterday
   - Run scheduler manually or wait for 6 AM
   - Open app → Pending Maintenance should show it

### Automated Test (Pytest)

```python
def test_notification_created_for_overdue_machine():
    # Create machine that's overdue
    machine = Machine(
        name="Test-001",
        next_maintenance_date=date.today() - timedelta(days=1),
        status="ACTIVE"
    )
    db.session.add(machine)
    db.session.commit()
    
    # Run scheduler
    from app.services.scheduler import check_due_machines
    check_due_machines(app)
    
    # Assert notification was created
    notification = Notification.query.filter_by(machine_id=machine.id).first()
    assert notification is not None
    assert notification.notification_type == "OVERDUE"
```

---

## 🚀 Future Enhancements

### Push Notifications (Optional)
If you want phone notifications even when app is closed, add Firebase Cloud Messaging:

1. Generate Firebase credentials
2. Install `firebase-admin` in backend
3. Send notification via Firebase when machine is due
4. Add Firebase plugin to Flutter app
5. Handle notification tap → open app to relevant machine

### Email Notifications (Optional)
If needed later, add SMTP to send emails alongside notifications:

```python
# In scheduler.py, after creating notification:
send_email_to_technician(
    tech.email,
    subject=f"Maintenance Due: {machine.name}",
    body=notification.message
)
```

### Notification Grouping (Optional)
Group multiple notifications by type:
- "3 machines overdue"
- "5 due today"
- "2 completed today"

---

## 📞 Troubleshooting

### Notifications Not Creating

**Check 1: Is scheduler running?**
```bash
# Start backend and look for this in logs:
[Scheduler] Started — daily check at 6:00 AM
```

**Check 2: Are there machines due?**
```sql
SELECT * FROM machines 
WHERE next_maintenance_date <= CURDATE() 
AND status = 'ACTIVE';
```

If empty → no machines are due, notifications won't create.

**Check 3: Are technicians active?**
```sql
SELECT * FROM users 
WHERE role = 'TECHNICIAN' 
AND is_active = TRUE;
```

If empty → no notifications will be created (no one to notify).

### User Not Seeing Notifications

**Check 1: Are they logged in?**
- Notifications are user-specific
- Must be authenticated to fetch

**Check 2: Check app logs**
```bash
flutter run -v
# Look for API errors when fetching notifications
```

**Check 3: Verify API response**
```bash
curl -H "Authorization: Bearer {token}" \
     http://localhost:5000/api/notifications/
```

Should return a list (empty `[]` if none, or populated list).

---

## ✅ Checklist — Notifications Working

- [ ] APScheduler starts when backend runs (see log message)
- [ ] Add a machine with `next_maintenance_date` = today
- [ ] Wait for 6 AM or trigger scheduler manually (restart backend)
- [ ] Notification appears in database: `SELECT * FROM notifications;`
- [ ] App fetches it: `GET /api/notifications/` returns the notification
- [ ] App displays it: Pending Maintenance screen shows machine
- [ ] Technician marks complete → notification type changes to COMPLETED

---

*Last updated: August 2026*
*MainHub Team*
