from apscheduler.schedulers.background import BackgroundScheduler
from datetime import date, datetime, timedelta, timezone


def check_due_machines(app, shift_label="Scheduled Check"):
    """
    Runs daily at 7:00 AM and 1:00 PM (13:00).
    Finds all machines due or overdue for maintenance and creates notifications.
    """
    with app.app_context():
        from app import db
        from app.models.machine import Machine
        from app.models.notification import Notification
        from app.models.user import User

        today = date.today()
        # find all active machines due today or overdue
        due_machines = Machine.query.filter(
            Machine.next_maintenance_date <= today,
            Machine.status == "ACTIVE"
        ).all()

        if not due_machines:
            print(f"[scheduler] {today} [{shift_label}] - NO machines due today.")
            return

        # get all technicians to notify
        # Notify both technicians and admins
        technicians = User.query.filter(
            User.role.in_(["TECHNICIAN", "ADMIN"]),
            User.is_active == True
        ).all()

        # Check existing notifications within the last 5 hours to prevent rapid duplicates,
        # while allowing both 7:00 AM and 1:00 PM shift notifications (6 hours apart)
        cutoff_time = datetime.now(timezone.utc) - timedelta(hours=5)
        existing_records = Notification.query.filter(
            Notification.created_at >= cutoff_time
        ).with_entities(
            Notification.machine_id,
            Notification.user_id,
            Notification.notification_type
        ).all()
        existing_set = set(existing_records)

        now_utc = datetime.now(timezone.utc)
        to_create = []

        for machine in due_machines:
            is_overdue = machine.next_maintenance_date < today
            notif_type = "OVERDUE" if is_overdue else "REMINDER"
            title      = f"{'⚠️ OVERDUE' if is_overdue else '🔔 Due Today'}: {machine.name}"
            message    = (
                f"Machine '{machine.name}' ({machine.type}) at {machine.location or 'N/A'} "
                f"{'was due on' if is_overdue else 'is due for'} maintenance "
                f"on {machine.next_maintenance_date}."
            )

            for tech in technicians:
                # Technicians only receive alerts for their department; Admins receive for all
                if tech.role == "TECHNICIAN" and tech.department and machine.department and tech.department != machine.department:
                    continue

                key = (machine.id, tech.id, notif_type)
                if key not in existing_set:
                    to_create.append(Notification(
                        machine_id=machine.id,
                        user_id=tech.id,
                        title=title,
                        message=message,
                        notification_type=notif_type,
                        is_sent=True,
                        sent_at=now_utc
                    ))
                    existing_set.add(key)

        if to_create:
            db.session.add_all(to_create)
            db.session.commit()
            print(f"[Scheduler] {today} [{shift_label}] — Created {len(to_create)} notification(s) for {len(due_machines)} machine(s).")
        else:
            print(f"[Scheduler] {today} [{shift_label}] — All notifications already up to date.")

def start_scheduler(app):
    scheduler = BackgroundScheduler()

    # Morning shift check at 7:00 AM
    scheduler.add_job(
        func=lambda: check_due_machines(app, shift_label="Morning Shift (7:00 AM)"),
        trigger="cron",
        hour=7,
        minute=0,
        id="morning_shift_check",
        replace_existing=True
    )

    # Afternoon shift check at 1:00 PM (13:00)
    scheduler.add_job(
        func=lambda: check_due_machines(app, shift_label="Afternoon Shift (1:00 PM)"),
        trigger="cron",
        hour=13,
        minute=0,
        id="afternoon_shift_check",
        replace_existing=True
    )

    scheduler.start()
    print("[scheduler] started - daily checks configured for 7:00 AM and 1:00 PM")

    # Run check immediately in background on startup if no recent notifications exist
    import threading
    threading.Thread(target=check_due_machines, args=(app, "Startup Check"), daemon=True).start()

    return scheduler