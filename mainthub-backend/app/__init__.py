from flask import Flask, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_jwt_extended import JWTManager
from flask_cors import CORS
from flask_marshmallow import Marshmallow
from dotenv import load_dotenv
from sqlalchemy import inspect, text
from werkzeug.exceptions import HTTPException
import os
import logging

load_dotenv()

# Extensions — initialized here, bound to app in create_app()
db = SQLAlchemy()
jwt = JWTManager()
ma = Marshmallow()


def _normalize_database_url(url: str) -> str:
    """Render/Railway/Heroku URLs need SQLAlchemy-compatible schemes."""
    if url.startswith("postgres://"):
        url = "postgresql://" + url[len("postgres://"):]
    if url.startswith("postgresql://") and not url.startswith("postgresql+"):
        url = "postgresql+psycopg2://" + url[len("postgresql://"):]
    if url.startswith("mysql://"):
        url = "mysql+pymysql://" + url[len("mysql://"):]
    return url


def _is_local_mysql(url: str) -> bool:
    return "mysql" in url and ("localhost" in url or "127.0.0.1" in url)


def _auto_migrate(app):
    """
    Idempotent migration to ensure schema consistency on deployment.
    Adds missing columns to existing tables and seeds a default admin user.
    """
    try:
        inspector = inspect(db.engine)
        tables = inspector.get_table_names()

        # 1. users table: ensure department and is_active exist
        if "users" in tables:
            user_cols = {c["name"] for c in inspector.get_columns("users")}
            if "department" not in user_cols:
                try:
                    db.session.execute(text("ALTER TABLE users ADD COLUMN department VARCHAR(50) NULL"))
                    db.session.commit()
                    app.logger.info("[migration] Added 'department' column to users table")
                except Exception as e:
                    db.session.rollback()
                    app.logger.warning(f"[migration] Could not add department to users: {e}")

            if "is_active" not in user_cols:
                try:
                    db.session.execute(text("ALTER TABLE users ADD COLUMN is_active BOOLEAN NOT NULL DEFAULT 1"))
                    db.session.commit()
                except Exception as e:
                    db.session.rollback()

        # 2. machines table: ensure department exists
        if "machines" in tables:
            machine_cols = {c["name"] for c in inspector.get_columns("machines")}
            if "department" not in machine_cols:
                try:
                    db.session.execute(text("ALTER TABLE machines ADD COLUMN department VARCHAR(50) NOT NULL DEFAULT 'BLOWROOM'"))
                    db.session.commit()
                    app.logger.info("[migration] Added 'department' column to machines table")
                except Exception as e:
                    db.session.rollback()
                    app.logger.warning(f"[migration] Could not add department to machines: {e}")

        # 3. Ensure default admin user admin@mainthub.com exists
        from app.models.user import User
        import bcrypt
        admin = User.query.filter_by(email="admin@mainthub.com").first()
        if not admin:
            password_hash = bcrypt.hashpw(b"admin123", bcrypt.gensalt()).decode("utf-8")
            default_admin = User(
                full_name="Admin User",
                email="admin@mainthub.com",
                password_hash=password_hash,
                role="ADMIN",
                department=None,
                is_active=True,
            )
            db.session.add(default_admin)
            db.session.commit()
            app.logger.info("[migration] Created default admin user admin@mainthub.com")

        # 4. Sync missing machines across all departments
        from app.models.machine import Machine
        try:
            from seed import MACHINES
            admin_user = User.query.filter_by(role="ADMIN").first()
            if admin_user:
                existing_names = {row[0] for row in db.session.query(Machine.name).all()}
                to_insert = [
                    Machine(
                        name=m["name"],
                        type=m["type"],
                        department=m["department"],
                        location=m["location"],
                        maintenance_interval=m["maintenance_interval"],
                        last_maintenance_date=m["last_maintenance_date"],
                        next_maintenance_date=m["next_maintenance_date"],
                        status="ACTIVE",
                        created_by=admin_user.id,
                    )
                    for m in MACHINES if m["name"] not in existing_names
                ]
                if to_insert:
                    db.session.add_all(to_insert)
                    db.session.commit()
                    app.logger.info(f"[migration] Seeded {len(to_insert)} missing machines across departments")
        except Exception as e:
            db.session.rollback()
            app.logger.warning(f"[migration] Machine sync error: {e}")

    except Exception as e:
        db.session.rollback()
        app.logger.error(f"[migration] Auto-migration error: {e}")


def _get_deployment_id() -> str:
    """
    Returns a persistent identifier for the current backend deployment build.
    This value remains identical across idle spin-downs and wake-ups on Render free tier,
    but changes whenever a new deployment/build is created.
    """
    # 1. Explicit environment variable override
    deploy_id = os.getenv("DEPLOY_ID") or os.getenv("BUILD_ID")
    if deploy_id and deploy_id.strip():
        return deploy_id.strip()

    # 2. Render Git commit SHA (injected by Render build environment)
    render_commit = os.getenv("RENDER_GIT_COMMIT")
    if render_commit and render_commit.strip():
        return render_commit.strip()

    # 3. Build ID file generated during deployment build step (e.g. render buildCommand / docker build)
    app_dir = os.path.dirname(os.path.abspath(__file__))
    candidates = [
        os.path.join(os.path.dirname(app_dir), "build_id.txt"),
        os.path.join(app_dir, "build_id.txt"),
    ]
    for c in candidates:
        if os.path.exists(c):
            try:
                with open(c, "r", encoding="utf-8") as f:
                    val = f.read().strip()
                    if val:
                        return val
            except Exception:
                pass

    # 4. Git commit from local repository if available
    try:
        import subprocess
        commit = subprocess.check_output(
            ["git", "rev-parse", "HEAD"],
            stderr=subprocess.DEVNULL,
            text=True
        ).strip()
        if commit:
            return commit
    except Exception:
        pass

    # 5. Default static fallback
    return "mainthub-static-deploy"


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
    app.config["SQLALCHEMY_ENGINE_OPTIONS"] = {
        "pool_pre_ping": True,
        "pool_recycle": 280,
    }

    # ── JWT and Session Persistence Configuration ───────────
    # Keep user logged in until the user decides to log out or backend redeploys.
    # JWT_ACCESS_TOKEN_EXPIRES = False disables automatic inactivity expiration.
    # Tying the secret key to deployment ID ensures older sessions are invalidated on redeployment.
    deployment_id = _get_deployment_id()
    base_secret = os.getenv(
        "JWT_SECRET_KEY",
        "dev-secret-change-in-production"
    )
    app.config["DEPLOYMENT_ID"] = deployment_id
    app.config["JWT_SECRET_KEY"] = f"{base_secret}:{deployment_id}"
    app.config["JWT_ACCESS_TOKEN_EXPIRES"] = False

    # ── Initialize extensions ────────────────────────────────
    db.init_app(app)
    jwt.init_app(app)
    ma.init_app(app)
    CORS(app)

    # ── JWT Error Handlers (consistently return 401 for auth rejections) ──
    @jwt.invalid_token_loader
    def _invalid_token_callback(reason):
        return jsonify({"error": "invalid_token", "message": f"Invalid token or backend redeployed: {reason}"}), 401

    @jwt.expired_token_loader
    def _expired_token_callback(header, payload):
        return jsonify({"error": "token_expired", "message": "Token has expired"}), 401

    @jwt.unauthorized_loader
    def _missing_token_callback(reason):
        return jsonify({"error": "authorization_required", "message": reason}), 401

    # ── Import models to register schemas for table creation ──
    from app.models.user import User
    from app.models.machine import Machine
    from app.models.maintenance import MaintenanceHistory
    from app.models.notification import Notification

    with app.app_context():
        db.create_all()
        _auto_migrate(app)

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

    def _health_check():
        db_status = "ok"
        error_msg = None
        try:
            db.session.execute(text("SELECT 1"))
        except Exception as e:
            db_status = "error"
            error_msg = str(e)

        resp = {
            "status": "ok",
            "database": db_status,
            "deployment_id": app.config.get("DEPLOYMENT_ID"),
        }
        if error_msg:
            resp["database_error"] = error_msg
        return jsonify(resp), (200 if db_status == "ok" else 500)

    @app.get("/health")
    def health():
        return _health_check()

    @app.get("/api/health")
    def api_health():
        return _health_check()

    # ── Global Error Handling ─────────────────────────────────
    @app.errorhandler(Exception)
    def handle_exception(e):
        if isinstance(e, HTTPException):
            return jsonify({"error": e.description}), e.code

        import traceback
        logging.error(f"Unhandled Exception: {e}\n{traceback.format_exc()}")
        return jsonify({
            "error": str(e),
            "type": type(e).__name__,
        }), 500

    # ── Start background scheduler ───────────────────────────
    from app.services.scheduler import start_scheduler
    start_scheduler(app)

    return app
