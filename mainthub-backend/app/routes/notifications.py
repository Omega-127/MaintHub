from flask import Blueprint, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app import db
from app.models.notification import Notification
from datetime import datetime, timezone

notifications_bp = Blueprint("notifications", __name__)


# ── GET /api/notifications ───────────────────────────────────
@notifications_bp.route("/", methods=["GET"])
@jwt_required()
def get_notifications():
    user_id = get_jwt_identity()
    notifs = (Notification.query
              .filter_by(user_id=int(user_id))
              .order_by(Notification.created_at.desc())
              .all())

    return jsonify([{
        "id":                n.id,
        "machine_id":        n.machine_id,
        "title":             n.title,
        "message":           n.message,
        "notification_type": n.notification_type,
        "is_read":           n.is_read,
        "created_at":        str(n.created_at)
    } for n in notifs]), 200


# ── PUT /api/notifications/<id>/read ─────────────────────────
@notifications_bp.route("/<int:notif_id>/read", methods=["PUT"])
@jwt_required()
def mark_read(notif_id):
    notif = Notification.query.get_or_404(notif_id)
    notif.is_read = True
    db.session.commit()
    return jsonify({"message": "Notification marked as read"}), 200
