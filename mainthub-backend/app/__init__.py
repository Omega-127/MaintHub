from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_jwt_extended import JWTManager
from flask_cors import CORS
from flask_marshmallow import Marshmallow
from dotenv import load_dotenv
import os

load_dotenv()

# Extensions — initialized here, bound to app in create_app()
db = SQLAlchemy()
jwt = JWTManager()
ma = Marshmallow()


def _normalize_database_url(url: str) -> str:
    """Render/Railway/Heroku URLs need SQLAlchemy-compatible schemes."""
    # Prefer psycopg2 (installed as psycopg2-binary). Newer SQLAlchemy may
    # default postgresql:// to psycopg v3, which we do not ship.
    if url.startswith("postgres://"):
        url = "postgresql://" + url[len("postgres://"):]
    if url.startswith("postgresql://") and not url.startswith("postgresql+"):
        url = "postgresql+psycopg2://" + url[len("postgresql://"):]
    if url.startswith("mysql://"):
        url = "mysql+pymysql://" + url[len("mysql://"):]
    return url


def _is_local_mysql(url: str) -> bool:
    return "mysql" in url and ("localhost" in url or "127.0.0.1" in url)


def create_app():
    app = Flask(__name__)

    # ── Config ──────────────────────────────────────────────
    db_url = _normalize_database_url(
        os.getenv(
            "DATABASE_URL",
            "mysql+pymysql://mainthub_user:mainthub_pass@localhost:3306/mainthub_db",
        )
    )
    # Dev convenience only: if local MySQL isn't running, fall back to SQLite.
    # Never override remote production URLs (Render MySQL/Postgres).
    if _is_local_mysql(db_url):
        import socket
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(0.5)
            res = sock.connect_ex(("127.0.0.1", 3306))
            sock.close()
            if res != 0:
                db_url = "sqlite:///mainthub.db"
        except Exception:
            db_url = "sqlite:///mainthub.db"

    app.config["SQLALCHEMY_DATABASE_URI"] = db_url
    app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False
    app.config["JWT_SECRET_KEY"] = os.getenv(
        "JWT_SECRET_KEY",
        "dev-secret-change-in-production"
    )

    # ── Initialize extensions ────────────────────────────────
    db.init_app(app)
    jwt.init_app(app)
    ma.init_app(app)
    CORS(app)

    # ── Import models to register schemas for table creation ──
    from app.models.user import User
    from app.models.machine import Machine
    from app.models.maintenance import MaintenanceHistory
    from app.models.notification import Notification

    with app.app_context():
        db.create_all()

    # ── Register blueprints (routes) ─────────────────────────
    from app.routes.auth        import auth_bp
    from app.routes.machines    import machines_bp
    from app.routes.maintenance import maintenance_bp
    from app.routes.dashboard   import dashboard_bp
    from app.routes.notifications import notifications_bp

    app.register_blueprint(auth_bp,          url_prefix="/api/auth")
    app.register_blueprint(machines_bp,      url_prefix="/api/machines")
    app.register_blueprint(maintenance_bp,   url_prefix="/api/maintenance")
    app.register_blueprint(dashboard_bp,     url_prefix="/api/dashboard")
    app.register_blueprint(notifications_bp, url_prefix="/api/notifications")

    @app.get("/health")
    def health():
        return {"status": "ok"}, 200

    # ── Start background scheduler ───────────────────────────
    from app.services.scheduler import start_scheduler
    start_scheduler(app)

    return app

