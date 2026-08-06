from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app import db
from app.models.machine import Machine
from app.models.maintenance import MaintenanceHistory
from datetime import datetime, date, time, timedelta, timezone

maintenance_bp = Blueprint("maintenance", __name__)

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