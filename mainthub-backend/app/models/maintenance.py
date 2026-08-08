from app import db
from datetime import datetime, timezone


class MaintenanceHistory(db.Model):
    __tablename__ = "maintenance_history"

    id               = db.Column(db.Integer,     primary_key=True)
    machine_id       = db.Column(db.Integer,     db.ForeignKey("machines.id"), nullable=False)
    technician_id    = db.Column(db.Integer,     db.ForeignKey("users.id"),    nullable=False)
    maintenance_date = db.Column(db.DateTime,    nullable=False, default=lambda: datetime.now(timezone.utc))
    status           = db.Column(db.String(50),  nullable=False, default="COMPLETED")
    notes            = db.Column(db.Text,        nullable=True)
    created_at       = db.Column(db.DateTime,    default=lambda: datetime.now(timezone.utc))

    def __repr__(self):
        return f"<MaintenanceHistory machine={self.machine_id} status={self.status}>"
