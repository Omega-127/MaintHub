from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app import db
from app.models.machine import Machine
from app.models.user import User
from datetime import date, timedelta

machines_bp = Blueprint("machines", __name__)

def calculate_next_data(last_date, interval_days):
    return last_date + timedelta(days=interval_days)

@machines_bp.route("/", methods=["GET"])
@jwt_required()

def get_machines():
    machines = Machine.query.all()
    return jsonify([{
        "id":                    m.id,
        "name":                  m.name,
        "type":                  m.type,
        "location":              m.location,
        "maintenance_interval":  m.maintenance_interval,
        "last_maintenance_date": str(m.last_maintenance_date) if m.last_maintenance_date else None,
        "next_maintenance_date": str(m.next_maintenance_date),
        "status":                m.status,
        "created_by":            m.created_by
    } for m in machines]), 200

@machines_bp.route("/<int:machine_id>", methods=["GET"])
@jwt_required()

def get_machine(machine_id):
    machine = Machine.query.get_or_404(machine_id)
    return jsonify({
        "id":                    machine.id,
        "name":                  machine.name,
        "type":                  machine.type,
        "location":              machine.location,
        "maintenance_interval":  machine.maintenance_interval,
        "last_maintenance_date": str(machine.last_maintenance_date) if machine.last_maintenance_date else None,
        "next_maintenance_date": str(machine.next_maintenance_date),
        "status":                machine.status,
        "created_by":            machine.created_by
    }), 200

@machines_bp.route("/", methods=["POST"])
@jwt_required()

def create_machine():
    user_id = get_jwt_identity()
    user = User.query.get(user_id)

    if user.role != "ADMIN":
        return jsonify({"error": "Admin access required"}), 403

    data = request.get_json()

    required = ["name", "type", "maintenance_interval", "first_maintenance_data"]

    for field in required:
        if not data.get(field):
            return jsonify({"error": f"{field} is required"}), 400

    try:
        first_date = date.fromisoformat(data['first_maintenance_date'])
    except ValueError:
        return jsonify({"error": "Invalid date format. Use YYYY-MM-DD"}), 400

    next_date = calculate_next_data(first_date, int(data['maintenance_interval']))

    machine = Machine(
        name=data["name"],
        type=data["type"],
        location=data.get("location"),
        maintenance_interval=int(data["maintenance_interval"]),
        last_maintenance_date=first_date,
        next_maintenance_date=next_date,
        created_by=int(user_id)
    )

    db.session.add(machine)
    db.session.commit()

    return jsonify({
        "message":               "Machine created successfully",
        "id":                    machine.id,
        "name":                  machine.name,
        "next_maintenance_date": str(machine.next_maintenance_date)
    }), 201

@machines_bp.route("/<int:machine_id>", methods=["PUT"])
@jwt_required()

def update_machine(machine_id):
    user_id = get_jwt_identity()
    user = User.query.get(user_id)

    if user.role != "ADMIN":
        return jsonify({"error": "Admin access required"}), 403

    machine = Machine.query.get_or_404(machine_id)
    data = request.get_json()

    if "name"     in data: machine.name     = data["name"]
    if "type"     in data: machine.type     = data["type"]
    if "location" in data: machine.location = data["location"]
    if "status"   in data: machine.status   = data["status"]

    if 'maintenance_interval' in data:
        machine.maintenance_interval = int(data["maintenance_interval"])
        if machine.last_maintenance_date:
            machine.next_maintenance_date = calculate_next_data(
                machine.last_maintenance_date,
                machine.maintenance_interval
            )

    db.session.commit()
    return jsonify({"message": "Machine updated successfully"}), 200

@machines_bp.route("/<int:machine_id>", methods=["DELETE"])
@jwt_required()

def delete_machine(machine_id):
    user_id = get_jwt_identity()
    user = User.query.get(user_id)

    if user.role != "ADMIN":
        return jsonify({"error": "Admin access required"}), 403

    machine = Machine.query.get_or_404(machine_id)

    db.session.delete(machine)
    db.session.commit()

    return jsonify({"message": "Machine deleted successfully"}), 200