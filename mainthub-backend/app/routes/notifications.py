from flask import Blueprint, jsonify, current_app
from flask_jwt_extended import jwt_required, get_jwt_identity
from app import db
from app.models.notification import Notification
from app.services.scheduler import check_due_machines
from datetime import datetime, timezone

import threading

notifications_bp = Blueprint("notifications", __name__)
_last_check_timestamp = None
_check_lock = threading.Lock()


# ── GET /api/notifications ───────────────────────────────────
@notifications_bp.route("/", methods=["GET"])
@jwt_required()
def get_notifications():
    global _last_check_timestamp
    now = datetime.now(timezone.utc)

    # Sync due/overdue machine notifications on demand (debounced to at most once every 10 minutes)
    should_sync = False
    with _check_lock:
        if _last_check_timestamp is None or (now - _last_check_timestamp).total_seconds() > 600:
            _last_check_timestamp = now
            should_sync = True

    if should_sync:
        try:
            app_obj = current_app._get_current_object()
            threading.Thread(target=check_due_machines, args=(app_obj,), daemon=True).start()
        except Exception as e:
            current_app.logger.warning(f"[notifications] sync check dispatch error: {e}")

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
