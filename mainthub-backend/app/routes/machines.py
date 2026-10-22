from flask import Blueprint, request, jsonify, send_file
from flask_jwt_extended import jwt_required, get_jwt_identity, decode_token
from app import db
from app.models.machine import Machine
from app.models.user import User
from app.services.export_service import generate_department_excel, generate_all_departments_excel
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
        if dept_filter and dept_filter in ("BLOWROOM", "COMBER", "RING_FRAME", "SPEED_FRAME", "WINDING", "BUFFING"):
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
    """Return the six available departments."""
    return jsonify(["BLOWROOM", "COMBER", "RING_FRAME", "SPEED_FRAME", "WINDING", "BUFFING"]), 200


# ── GET /api/machines/export ──────────────────────────────────
# ── GET /api/machines/export/<department> ─────────────────────
@machines_bp.route("/export", methods=["GET"])
@machines_bp.route("/export/<department>", methods=["GET"])
@jwt_required(optional=True)
def export_department_excel(department=None):
    """
    Export Excel maintenance schedule for a department.
    Contains: Department title, all machines, previous maintenance date,
    due date, and historical maintenance cycles as column pairs.
    """
    user_id = get_jwt_identity()
    if not user_id:
        token = request.args.get("token")
        if token:
            try:
                decoded = decode_token(token)
                user_id = decoded["sub"]
            except Exception:
                return jsonify({"error": "Invalid or expired token"}), 401
        else:
            return jsonify({"error": "Authorization token required"}), 401

    user = User.query.get(user_id)
    if not user:
        return jsonify({"error": "User not found"}), 404

    valid_depts = ("BLOWROOM", "COMBER", "RING_FRAME", "SPEED_FRAME", "WINDING", "BUFFING")
    target_dept = department or request.args.get("department")

    # Technicians are restricted to their own department
    if user.role != "ADMIN":
        target_dept = user.department
        if not target_dept:
            return jsonify({"error": "Technician has no assigned department"}), 400

    if not target_dept or target_dept.upper() == "ALL":
        if user.role != "ADMIN":
            target_dept = user.department
        else:
            # Multi-department export: 1 sheet per department
            dept_dict = {}
            for d in valid_depts:
                dept_dict[d] = Machine.query.filter_by(department=d).order_by(Machine.name.asc()).all()
            excel_buf = generate_all_departments_excel(dept_dict)
            filename = f"MaintHub_All_Departments_{date.today().strftime('%Y%m%d')}.xlsx"
            return send_file(
                excel_buf,
                mimetype="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                as_attachment=True,
                download_name=filename,
            )

    if not target_dept:
        return jsonify({"error": "No department specified"}), 400

    target_dept = target_dept.upper()
    if target_dept not in valid_depts:
        return jsonify({"error": f"Invalid department. Must be one of: {', '.join(valid_depts)}"}), 400

    machines = Machine.query.filter_by(department=target_dept).order_by(Machine.name.asc()).all()
    excel_buf = generate_department_excel(target_dept, machines)
    filename = f"{target_dept}_Maintenance_Schedule_{date.today().strftime('%Y%m%d')}.xlsx"

    return send_file(
        excel_buf,
        mimetype="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        as_attachment=True,
        download_name=filename,
    )


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

    if data["department"] not in ("BLOWROOM", "COMBER", "RING_FRAME", "SPEED_FRAME", "WINDING", "BUFFING"):
        return jsonify({"error": "department must be BLOWROOM, COMBER, RING_FRAME, SPEED_FRAME, WINDING or BUFFING"}), 400

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
    data = request.get_json() or {}

    if "name" in data and data["name"]:
        machine.name = data["name"].strip()
    if "type" in data and data["type"]:
        machine.type = data["type"].strip()
    if "department" in data and data["department"]:
        dept = data["department"].strip().upper()
        if dept not in ("BLOWROOM", "COMBER", "RING_FRAME", "SPEED_FRAME", "WINDING", "BUFFING"):
            return jsonify({"error": "Invalid department"}), 400
        machine.department = dept
    if "location" in data:
        machine.location = data["location"].strip() if data["location"] else None
    if "status" in data and data["status"]:
        status = data["status"].strip().upper()
        if status not in ("ACTIVE", "INACTIVE", "UNDER_MAINTENANCE"):
            return jsonify({"error": "Invalid status"}), 400
        machine.status = status

    interval_changed = False
    if "maintenance_interval" in data and data["maintenance_interval"] is not None:
        try:
            machine.maintenance_interval = int(data["maintenance_interval"])
            interval_changed = True
        except (ValueError, TypeError):
            return jsonify({"error": "maintenance_interval must be an integer"}), 400

    last_date_changed = False
    if "last_maintenance_date" in data:
        if data["last_maintenance_date"]:
            try:
                machine.last_maintenance_date = date.fromisoformat(str(data["last_maintenance_date"]).split("T")[0])
                last_date_changed = True
            except ValueError:
                return jsonify({"error": "Invalid last_maintenance_date. Use YYYY-MM-DD"}), 400
        else:
            machine.last_maintenance_date = None

    if "next_maintenance_date" in data and data["next_maintenance_date"]:
        try:
            machine.next_maintenance_date = date.fromisoformat(str(data["next_maintenance_date"]).split("T")[0])
        except ValueError:
            return jsonify({"error": "Invalid next_maintenance_date. Use YYYY-MM-DD"}), 400
    elif (interval_changed or last_date_changed) and machine.last_maintenance_date:
        machine.next_maintenance_date = calculate_next_date(
            machine.last_maintenance_date,
            machine.maintenance_interval
        )

    db.session.commit()
    return jsonify({
        "message": "Machine updated successfully",
        "machine": machine_to_dict(machine)
    }), 200


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