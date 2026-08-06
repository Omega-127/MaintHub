from flask import Blueprint, request, jsonify
from flask_jwt_extended import create_access_token, jwt_required, get_jwt_identity
from app import db
from app.models.user import User
import bcrypt

auth_bp = Blueprint("auth", __name__)


# ── POST /api/auth/register ──────────────────────────────────
@auth_bp.route("/register", methods=["POST"])
def register():
    data = request.get_json()

    # Validate required fields
    required = ["full_name", "email", "password", "role"]
    for field in required:
        if not data.get(field):
            return jsonify({"error": f"{field} is required"}), 400

    # Check email not already taken
    if User.query.filter_by(email=data["email"]).first():
        return jsonify({"error": "Email already registered"}), 409

    # Validate role
    if data["role"] not in ["ADMIN", "TECHNICIAN"]:
        return jsonify({"error": "Role must be ADMIN or TECHNICIAN"}), 400

    # Hash password
    password_hash = bcrypt.hashpw(
        data["password"].encode("utf-8"),
        bcrypt.gensalt()
    ).decode("utf-8")

    # Create user
    user = User(
        full_name=data["full_name"],
        email=data["email"],
        password_hash=password_hash,
        role=data["role"]
    )
    db.session.add(user)
    db.session.commit()

    return jsonify({
        "message": "User registered successfully",
        "user": {
            "id":        user.id,
            "full_name": user.full_name,
            "email":     user.email,
            "role":      user.role
        }
    }), 201


# ── POST /api/auth/login ─────────────────────────────────────
@auth_bp.route("/login", methods=["POST"])
def login():
    data = request.get_json()

    if not data.get("email") or not data.get("password"):
        return jsonify({"error": "Email and password are required"}), 400

    # Find user
    user = User.query.filter_by(email=data["email"]).first()
    if not user or not user.is_active:
        return jsonify({"error": "Invalid credentials"}), 401

    # Check password
    if not bcrypt.checkpw(data["password"].encode("utf-8"), user.password_hash.encode("utf-8")):
        return jsonify({"error": "Invalid credentials"}), 401

    # Generate JWT
    access_token = create_access_token(identity=str(user.id))

    return jsonify({
        "access_token": access_token,
        "user": {
            "id":        user.id,
            "full_name": user.full_name,
            "email":     user.email,
            "role":      user.role
        }
    }), 200


# ── GET /api/auth/me ─────────────────────────────────────────
@auth_bp.route("/me", methods=["GET"])
@jwt_required()
def me():
    user_id = get_jwt_identity()
    user = User.query.get(user_id)
    if not user:
        return jsonify({"error": "User not found"}), 404

    return jsonify({
        "id":        user.id,
        "full_name": user.full_name,
        "email":     user.email,
        "role":      user.role
    }), 200
