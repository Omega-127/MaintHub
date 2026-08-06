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


def create_app():
    app = Flask(__name__)

    # ── Config ──────────────────────────────────────────────
    app.config["SQLALCHEMY_DATABASE_URI"] = os.getenv(
        "DATABASE_URL",
        "mysql+pymysql://mainthub_user:mainthub_pass@localhost:3306/mainthub_db"
    )
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

    # ── Start background scheduler ───────────────────────────
    from app.services.scheduler import start_scheduler
    start_scheduler(app)

    return app

