from app import db
from datetime import datetime, timezone


class Machine(db.Model):
    __tablename__ = "machines"

    id                     = db.Column(db.Integer,     primary_key=True)
    name                   = db.Column(db.String(255), nullable=False)
    type                   = db.Column(db.String(100), nullable=False)
    department             = db.Column(
                                 db.Enum("BLOWROOM", "COMBER", "RING_FRAME", "SPEED_FRAME", "WINDING", "BUFFING", name="machine_department", native_enum=False, length=20),
                                 nullable=False,
                                 default="BLOWROOM",
                             )
    location               = db.Column(db.String(255))
    maintenance_interval   = db.Column(db.Integer,     nullable=False)   # days
    last_maintenance_date  = db.Column(db.Date,        nullable=True)
    next_maintenance_date  = db.Column(db.Date,        nullable=False)
    status                 = db.Column(
                                db.Enum(
                                    "ACTIVE", "INACTIVE", "UNDER_MAINTENANCE",
                                    name="machine_status",
                                    native_enum=False,
                                    length=32,
                                ),
                                nullable=False,
                                default="ACTIVE",
                             )
    created_by             = db.Column(db.Integer, db.ForeignKey("users.id"), nullable=False)
    created_at             = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc))
    updated_at             = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc),
                                                    onupdate=lambda: datetime.now(timezone.utc))

    # Relationships
    maintenance_histories = db.relationship("MaintenanceHistory", backref="machine", lazy=True, cascade="all, delete-orphan")
    notifications         = db.relationship("Notification",       backref="machine", lazy=True, cascade="all, delete-orphan")

    def __repr__(self):
        return f"<Machine {self.name} | Next: {self.next_maintenance_date}>"
