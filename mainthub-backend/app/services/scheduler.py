from apscheduler.schedulers.background import BackgroundScheduler
from datetime import date, datetime, timezone


def check_due_machines(app):
    """
    Runs daily at 6 AM.
    Find all machines due for maintenance and creates notification.
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
            print(f"[scheduler] {today} - NO machines due today.")
            return


        # get all technicians to notify
        technicians = User.query.filter_by(role="TECHNICIAN", is_active=True).all()

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
                # Avoid duplicate notifications for same machine+user on same day
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
        print(f"[Scheduler] {today} — Notifications created for {len(due_machines)} machine(s).")

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
    print("[schedular] started - daily check at 6:00 AM")
    return scheduler