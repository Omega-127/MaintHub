from app import db
from datetime import datetime, timezone


class Notification(db.Model):
    __tablename__ = "notifications"

    id                = db.Column(db.Integer,     primary_key=True)
    machine_id        = db.Column(db.Integer,     db.ForeignKey("machines.id"), nullable=False)
    user_id           = db.Column(db.Integer,     db.ForeignKey("users.id"),    nullable=False)
    title             = db.Column(db.String(255), nullable=False)
    message           = db.Column(db.Text,        nullable=False)
    notification_type = db.Column(
                            db.Enum("REMINDER", "OVERDUE", "COMPLETED"),
                            nullable=False,
                            default="REMINDER"
                        )
    is_sent           = db.Column(db.Boolean,  default=False)
    is_read           = db.Column(db.Boolean,  default=False)
    sent_at           = db.Column(db.DateTime, nullable=True)
    created_at        = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc))

    def __repr__(self):
        return f"<Notification {self.notification_type} | read={self.is_read}>"