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