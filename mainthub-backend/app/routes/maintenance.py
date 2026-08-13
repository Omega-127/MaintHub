from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app import db
from app.models.machine import Machine
from app.models.maintenance import MaintenanceHistory
from app.models.user import User
from datetime import datetime, date, timedelta, timezone

maintenance_bp = Blueprint("maintenance", __name__)


# ── POST /api/maintenance/<machine_id>/complete ───────────────
@maintenance_bp.route("/<int:machine_id>/complete", methods=["POST"])
@jwt_required()
def mark_complete(machine_id):
    user_id = get_jwt_identity()
    data = request.get_json() or {}

    machine = Machine.query.get_or_404(machine_id)

    today = date.today()

    record = MaintenanceHistory(
        machine_id=machine_id,
        technician_id=int(user_id),
        maintenance_date=datetime.now(timezone.utc),
        status="COMPLETED",
        notes=data.get("notes", "")
    )

    db.session.add(record)

    machine.last_maintenance_date = today
    machine.next_maintenance_date = today + timedelta(days=machine.maintenance_interval)
    machine.status = "ACTIVE"

    db.session.commit()

    return jsonify({
        "message":               "Maintenance marked as complete",
        "next_maintenance_date": str(machine.next_maintenance_date)
    }), 200


# ── GET /api/maintenance/<machine_id>/history ─────────────────
@maintenance_bp.route("/<int:machine_id>/history", methods=["GET"])
@jwt_required()
def get_history(machine_id):
    Machine.query.get_or_404(machine_id)

    records = (MaintenanceHistory.query
               .filter_by(machine_id=machine_id)
               .order_by(MaintenanceHistory.maintenance_date.desc())
               .all())

    return jsonify([{
        "id":               r.id,
        "maintenance_date": str(r.maintenance_date),
        "status":           r.status,
        "notes":            r.notes,
        "technician_id":    r.technician_id
    } for r in records]), 200


# ── GET /api/maintenance/due ──────────────────────────────────
@maintenance_bp.route("/due", methods=["GET"])
@jwt_required()
def get_due():
    """Return all active machines that are due or overdue for maintenance."""
    today = date.today()
    due_machines = Machine.query.filter(
        Machine.next_maintenance_date <= today,
        Machine.status == "ACTIVE"
    ).order_by(Machine.next_maintenance_date.asc()).all()

    return jsonify([{
        "id":                    m.id,
        "name":                  m.name,
        "type":                  m.type,
        "location":              m.location,
        "maintenance_interval":  m.maintenance_interval,
        "last_maintenance_date": str(m.last_maintenance_date) if m.last_maintenance_date else None,
        "next_maintenance_date": str(m.next_maintenance_date),
        "status":                m.status,
        "days_overdue":          (today - m.next_maintenance_date).days
    } for m in due_machines]), 200


# ── GET /api/maintenance/history ─────────────────────────────
@maintenance_bp.route("/history", methods=["GET"])
@jwt_required()
def get_global_history():
    """Return the most recent maintenance records across all machines."""
    limit = request.args.get("limit", 20, type=int)

    records = (MaintenanceHistory.query
               .order_by(MaintenanceHistory.maintenance_date.desc())
               .limit(limit)
               .all())

    result = []
    for r in records:
        machine = Machine.query.get(r.machine_id)
        tech    = User.query.get(r.technician_id)
        result.append({
            "id":               r.id,
            "machine_id":       r.machine_id,
            "machine_name":     machine.name if machine else "Unknown",
            "technician_id":    r.technician_id,
            "technician_name":  tech.full_name if tech else "Unknown",
            "maintenance_date": str(r.maintenance_date),
            "status":           r.status,
            "notes":            r.notes,
        })

    return jsonify(result), 200