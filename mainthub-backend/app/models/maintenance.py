from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app import db
from app.models.machine import Machine
from app.models.maintenance import MaintenanceHistory
from datetime import datetime, date, time, timedelta, timezone

maintenance_bp = Blueprint("maintenance", __name__)

