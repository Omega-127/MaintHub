from app import db
from datetime import datetime, timezone


class User(db.Model):
    __tablename__ = "users"

    id            = db.Column(db.Integer,     primary_key=True)
    full_name     = db.Column(db.String(255), nullable=False)
    email         = db.Column(db.String(255), nullable=False, unique=True)
    password_hash = db.Column(db.String(255), nullable=False)
    role          = db.Column(
                        db.Enum("ADMIN", "TECHNICIAN", name="user_role", native_enum=False, length=20),
                        nullable=False,
                        default="TECHNICIAN",
                    )
    department    = db.Column(
                        db.Enum("BLOWROOM", "COMBER", "RING_FRAME", "SPEED_FRAME", name="user_department", native_enum=False, length=20),
                        nullable=True,   # NULL = Admin (sees all departments)
                    )
    is_active     = db.Column(db.Boolean,     nullable=False, default=True)
    created_at    = db.Column(db.DateTime,    default=lambda: datetime.now(timezone.utc))
    updated_at    = db.Column(db.DateTime,    default=lambda: datetime.now(timezone.utc),
                                            onupdate=lambda: datetime.now(timezone.utc))

    # Relationships
    machines              = db.relationship("Machine",            backref="creator",     lazy=True)
    maintenance_histories = db.relationship("MaintenanceHistory", backref="technician",  lazy=True)
    notifications         = db.relationship("Notification",       backref="recipient",   lazy=True)

    def __repr__(self):
        return f"<User {self.email} ({self.role})>"

    

