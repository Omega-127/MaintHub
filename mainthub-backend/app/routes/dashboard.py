from flask import jsonify
from flask_jwt_extended import jwt_required
from app.models.machine import Machine
from app.models.maintenance import MaintenanceHistory
from datetime import date

dashboard_bp = Blueprint("dashboard", __name__)

from flask import Blueprint
dashboard_bp = Blueprint("dashboard", __name__)


# ── GET /api/dashboard ───────────────────────────────────────
@dashboard_bp.route("/", methods=["GET"])
@jwt_required()
def get_dashboard():
    today = date.today()
    all_machines = Machine.query.all()

    total    = len(all_machines)
    active   = sum(1 for m in all_machines if m.status == "ACTIVE")
    inactive = sum(1 for m in all_machines if m.status == "INACTIVE")
    under_maintenance = sum(1 for m in all_machines if m.status == "UNDER_MAINTENANCE")

    # Overdue = next_maintenance_date is in the past and machine is active
    overdue  = sum(1 for m in all_machines if m.next_maintenance_date < today and m.status == "ACTIVE")

    # Due today or upcoming in next 7 days
    upcoming = sum(1 for m in all_machines
                   if today <= m.next_maintenance_date <= date.fromordinal(today.toordinal() + 7)
                   and m.status == "ACTIVE")

    # Recent completed maintenance (last 5)
    recent = (MaintenanceHistory.query
              .filter_by(status="COMPLETED")
              .order_by(MaintenanceHistory.maintenance_date.desc())
              .limit(5)
              .all())

    return jsonify({
        "summary": {
            "total_machines":    total,
            "active":            active,
            "inactive":          inactive,
            "under_maintenance": under_maintenance,
            "overdue":           overdue,
            "upcoming_7_days":   upcoming
        },
        "recent_maintenance": [{
            "id":               r.id,
            "machine_id":       r.machine_id,
            "maintenance_date": str(r.maintenance_date),
            "status":           r.status,
            "technician_id":    r.technician_id
        } for r in recent]
    }), 200
