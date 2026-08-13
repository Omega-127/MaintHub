from flask import Blueprint, jsonify
from flask_jwt_extended import jwt_required
from app.models.machine import Machine
from app.models.maintenance import MaintenanceHistory
from app.models.user import User
from datetime import date

dashboard_bp = Blueprint("dashboard", __name__)


# ── GET /api/dashboard ───────────────────────────────────────
@dashboard_bp.route("/", methods=["GET"])
@jwt_required()
def get_dashboard():
    today        = date.today()
    all_machines = Machine.query.all()

    total             = len(all_machines)
    active            = sum(1 for m in all_machines if m.status == "ACTIVE")
    inactive          = sum(1 for m in all_machines if m.status == "INACTIVE")
    under_maintenance = sum(1 for m in all_machines if m.status == "UNDER_MAINTENANCE")

    # Overdue = next_maintenance_date is in the past and machine is ACTIVE
    overdue  = sum(1 for m in all_machines if m.next_maintenance_date < today and m.status == "ACTIVE")

    # Due today or in the next 7 days
    upcoming = sum(
        1 for m in all_machines
        if today <= m.next_maintenance_date <= date.fromordinal(today.toordinal() + 7)
        and m.status == "ACTIVE"
    )

    # Top 5 most overdue machines (for quick-action widget)
    overdue_list = sorted(
        [m for m in all_machines if m.next_maintenance_date < today and m.status == "ACTIVE"],
        key=lambda m: m.next_maintenance_date
    )[:5]

    # Recent completed maintenance (last 10), enriched with names
    recent_records = (MaintenanceHistory.query
                      .order_by(MaintenanceHistory.maintenance_date.desc())
                      .limit(10)
                      .all())

    recent = []
    for r in recent_records:
        machine = Machine.query.get(r.machine_id)
        tech    = User.query.get(r.technician_id)
        recent.append({
            "id":               r.id,
            "machine_id":       r.machine_id,
            "machine_name":     machine.name if machine else "Unknown",
            "technician_id":    r.technician_id,
            "technician_name":  tech.full_name if tech else "Unknown",
            "maintenance_date": str(r.maintenance_date),
            "status":           r.status,
        })

    return jsonify({
        "summary": {
            "total_machines":    total,
            "active":            active,
            "inactive":          inactive,
            "under_maintenance": under_maintenance,
            "overdue":           overdue,
            "upcoming_7_days":   upcoming
        },
        "overdue_machines": [{
            "id":                    m.id,
            "name":                  m.name,
            "type":                  m.type,
            "location":              m.location,
            "next_maintenance_date": str(m.next_maintenance_date),
            "days_overdue":          (today - m.next_maintenance_date).days
        } for m in overdue_list],
        "recent_maintenance": recent
    }), 200

