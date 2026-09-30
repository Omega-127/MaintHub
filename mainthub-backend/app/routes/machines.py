from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app import db
from app.models.machine import Machine
from app.models.user import User
from datetime import date, timedelta

machines_bp = Blueprint("machines", __name__)


def calculate_next_date(last_date, interval_days):
    return last_date + timedelta(days=interval_days)


def machine_to_dict(m):
    return {
        "id":                    m.id,
        "name":                  m.name,
        "type":                  m.type,
        "department":            m.department,
        "location":              m.location,
        "maintenance_interval":  m.maintenance_interval,
        "last_maintenance_date": str(m.last_maintenance_date) if m.last_maintenance_date else None,
        "next_maintenance_date": str(m.next_maintenance_date),
        "status":                m.status,
        "created_by":            m.created_by,
    }


# ── GET /api/machines/ ───────────────────────────────────────
@machines_bp.route("/", methods=["GET"])
@jwt_required()
def get_machines():
    user_id = get_jwt_identity()
    user    = User.query.get(user_id)

    query = Machine.query

    # Admins can filter by department via ?department=BLOWROOM|COMBER
    # Technicians are automatically restricted to their own department
    if user.role == "ADMIN":
        dept_filter = request.args.get("department")
        if dept_filter and dept_filter in ("BLOWROOM", "COMBER"):
            query = query.filter(Machine.department == dept_filter)
    else:
        # Technicians only see their department
        if user.department:
            query = query.filter(Machine.department == user.department)

    machines = query.all()
    return jsonify([machine_to_dict(m) for m in machines]), 200


# ── GET /api/machines/types ──────────────────────────────────
@machines_bp.route("/types", methods=["GET"])
@jwt_required()
def get_machine_types():
    """Return distinct machine type values (e.g. Blowroom, Carding)."""
    rows = db.session.query(Machine.type).distinct().order_by(Machine.type).all()
    return jsonify([r[0] for r in rows]), 200


# ── GET /api/machines/departments ───────────────────────────
@machines_bp.route("/departments", methods=["GET"])
@jwt_required()
def get_departments():
    """Return the two available departments."""
    return jsonify(["BLOWROOM", "COMBER"]), 200


# ── GET /api/machines/due ────────────────────────────────────
@machines_bp.route("/due", methods=["GET"])
@jwt_required()
def get_due_machines():
    """Return all active machines whose next_maintenance_date <= today."""
    user_id = get_jwt_identity()
    user    = User.query.get(user_id)
    today   = date.today()

    query = Machine.query.filter(
        Machine.next_maintenance_date <= today,
        Machine.status == "ACTIVE"
    )

    if user.role != "ADMIN" and user.department:
        query = query.filter(Machine.department == user.department)

    due = query.order_by(Machine.next_maintenance_date.asc()).all()

    return jsonify([{
        **machine_to_dict(m),
        "days_overdue": (today - m.next_maintenance_date).days
    } for m in due]), 200


# ── GET /api/machines/<id> ───────────────────────────────────
@machines_bp.route("/<int:machine_id>", methods=["GET"])
@jwt_required()
def get_machine(machine_id):
    machine = Machine.query.get_or_404(machine_id)
    return jsonify(machine_to_dict(machine)), 200


# ── POST /api/machines/ ──────────────────────────────────────
@machines_bp.route("/", methods=["POST"])
@jwt_required()
def create_machine():
    user_id = get_jwt_identity()
    user = User.query.get(user_id)

    if user.role != "ADMIN":
        return jsonify({"error": "Admin access required"}), 403

    data = request.get_json()

    required = ["name", "type", "department", "maintenance_interval", "first_maintenance_date"]

    for field in required:
        if not data.get(field):
            return jsonify({"error": f"{field} is required"}), 400

    if data["department"] not in ("BLOWROOM", "COMBER"):
        return jsonify({"error": "department must be BLOWROOM or COMBER"}), 400

    try:
        first_date = date.fromisoformat(data["first_maintenance_date"])
    except ValueError:
        return jsonify({"error": "Invalid date format. Use YYYY-MM-DD"}), 400

    next_date = calculate_next_date(first_date, int(data["maintenance_interval"]))

    machine = Machine(
        name=data["name"],
        type=data["type"],
        department=data["department"],
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
        "department":            machine.department,
        "next_maintenance_date": str(machine.next_maintenance_date)
    }), 201


# ── PUT /api/machines/<id> ───────────────────────────────────
@machines_bp.route("/<int:machine_id>", methods=["PUT"])
@jwt_required()
def update_machine(machine_id):
    user_id = get_jwt_identity()
    user = User.query.get(user_id)

    if user.role != "ADMIN":
        return jsonify({"error": "Admin access required"}), 403

    machine = Machine.query.get_or_404(machine_id)
    data = request.get_json()

    if "name"       in data: machine.name       = data["name"]
    if "type"       in data: machine.type       = data["type"]
    if "department" in data: machine.department = data["department"]
    if "location"   in data: machine.location   = data["location"]
    if "status"     in data: machine.status     = data["status"]

    if "maintenance_interval" in data:
        machine.maintenance_interval = int(data["maintenance_interval"])
        if machine.last_maintenance_date:
            machine.next_maintenance_date = calculate_next_date(
                machine.last_maintenance_date,
                machine.maintenance_interval
            )

    db.session.commit()
    return jsonify({"message": "Machine updated successfully"}), 200


# ── DELETE /api/machines/<id> ────────────────────────────────
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