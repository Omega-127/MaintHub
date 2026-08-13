"""
seed.py — Populate the database with machines from the Excel schedule.

Usage:
    python seed.py

Works with both SQLite (dev) and MySQL (prod) — uses the same DATABASE_URL
from your .env file via the Flask app context.
Idempotent: skips machines that already exist (matched by name).
"""

from app import create_app, db
from app.models.machine import Machine
from app.models.user import User
from datetime import date

app = create_app()

# ── Machine seed data (sourced from Blowroom_Carding_Maintenance_Schedule.xlsx) ──
MACHINES = [
    # ── Blowroom ─────────────────────────────────────────────────────────────────
    {
        "name":                  "Bale Plucking Rolls",
        "type":                  "Blowroom",
        "location":              "Blowroom Section",
        "maintenance_interval":  1826,                  # ~5 years
        "last_maintenance_date": date(2023, 8, 2),
        "next_maintenance_date": date(2028, 8, 2),
    },
    {
        "name":                  "Bale Plucker Lifting Belt",
        "type":                  "Blowroom",
        "location":              "Blowroom Section",
        "maintenance_interval":  1826,
        "last_maintenance_date": date(2021, 5, 25),
        "next_maintenance_date": date(2026, 5, 25),
    },
    {
        "name":                  "Bale Plucker Up & Down Cam Roll Bearing",
        "type":                  "Blowroom",
        "location":              "Blowroom Section",
        "maintenance_interval":  730,                   # ~2 years
        "last_maintenance_date": date(2024, 3, 2),
        "next_maintenance_date": date(2026, 3, 2),
    },
    {
        "name":                  "Chute Feed Opener Roll Nitrate (A1-A4, B1-B4)",
        "type":                  "Blowroom",
        "location":              "Blowroom Section",
        "maintenance_interval":  730,
        "last_maintenance_date": date(2023, 9, 6),
        "next_maintenance_date": date(2025, 9, 6),
    },
    {
        "name":                  "Unimix Beater Wire",
        "type":                  "Blowroom",
        "location":              "Blowroom Section",
        "maintenance_interval":  912,                   # ~2.5 years
        "last_maintenance_date": date(2025, 12, 17),
        "next_maintenance_date": date(2028, 6, 17),
    },
    {
        "name":                  "Unimix Feed Roll Bearing",
        "type":                  "Blowroom",
        "location":              "Blowroom Section",
        "maintenance_interval":  1826,
        "last_maintenance_date": date(2018, 6, 18),
        "next_maintenance_date": date(2023, 6, 18),    # OVERDUE
    },
    {
        "name":                  "Unimix Gear Index",
        "type":                  "Blowroom",
        "location":              "Blowroom Section",
        "maintenance_interval":  730,
        "last_maintenance_date": date(2025, 1, 17),
        "next_maintenance_date": date(2027, 1, 17),
    },
    {
        "name":                  "Flexiclean Beater Wire",
        "type":                  "Blowroom",
        "location":              "Blowroom Section",
        "maintenance_interval":  912,
        "last_maintenance_date": date(2024, 3, 16),
        "next_maintenance_date": date(2026, 3, 16),
    },
    {
        "name":                  "Flexiclean Feed Roll Bearing",
        "type":                  "Blowroom",
        "location":              "Blowroom Section",
        "maintenance_interval":  1826,
        "last_maintenance_date": date(2018, 6, 18),
        "next_maintenance_date": date(2023, 6, 18),    # OVERDUE
    },
    {
        "name":                  "Flexiclean Fluted Roll (Rubber)",
        "type":                  "Blowroom",
        "location":              "Blowroom Section",
        "maintenance_interval":  730,
        "last_maintenance_date": date(2024, 3, 2),
        "next_maintenance_date": date(2026, 3, 2),
    },
    {
        "name":                  "Condensor Cage Drum",
        "type":                  "Blowroom",
        "location":              "Blowroom Section",
        "maintenance_interval":  1826,
        "last_maintenance_date": date(2019, 5, 2),
        "next_maintenance_date": date(2024, 5, 2),     # OVERDUE
    },
    {
        "name":                  "Primer i-Qube (CCS) LED/UV Tubes",
        "type":                  "Blowroom",
        "location":              "Blowroom Section",
        "maintenance_interval":  730,
        "last_maintenance_date": date(2025, 2, 1),
        "next_maintenance_date": date(2027, 2, 1),
    },
    # ── Carding (Flat/Cylinder/Doffer Wire Overhauling — ~26 months / 600 tons) ─
    {
        "name":                  "Card A1 - Flat/Cylinder/Doffer Wire",
        "type":                  "Carding",
        "location":              "Carding Section",
        "maintenance_interval":  791,
        "last_maintenance_date": date(2025, 2, 2),
        "next_maintenance_date": date(2027, 4, 2),
    },
    {
        "name":                  "Card A2 - Flat/Cylinder/Doffer Wire",
        "type":                  "Carding",
        "location":              "Carding Section",
        "maintenance_interval":  791,
        "last_maintenance_date": date(2024, 9, 6),
        "next_maintenance_date": date(2026, 11, 6),
    },
    {
        "name":                  "Card A3 - Flat/Cylinder/Doffer Wire",
        "type":                  "Carding",
        "location":              "Carding Section",
        "maintenance_interval":  791,
        "last_maintenance_date": date(2025, 3, 7),
        "next_maintenance_date": date(2027, 5, 7),
    },
    {
        "name":                  "Card A4 - Flat/Cylinder/Doffer Wire",
        "type":                  "Carding",
        "location":              "Carding Section",
        "maintenance_interval":  791,
        "last_maintenance_date": date(2024, 5, 18),
        "next_maintenance_date": date(2026, 7, 18),
    },
    {
        "name":                  "Card A5 - Flat/Cylinder/Doffer Wire",
        "type":                  "Carding",
        "location":              "Carding Section",
        "maintenance_interval":  791,
        "last_maintenance_date": date(2024, 4, 16),
        "next_maintenance_date": date(2026, 6, 16),
    },
    {
        "name":                  "Card A6 - Flat/Cylinder/Doffer Wire",
        "type":                  "Carding",
        "location":              "Carding Section",
        "maintenance_interval":  791,
        "last_maintenance_date": date(2024, 12, 16),
        "next_maintenance_date": date(2027, 2, 16),
    },
    {
        "name":                  "Card B1 - Flat/Cylinder/Doffer Wire",
        "type":                  "Carding",
        "location":              "Carding Section",
        "maintenance_interval":  791,
        "last_maintenance_date": date(2025, 6, 19),
        "next_maintenance_date": date(2027, 8, 19),
    },
    {
        "name":                  "Card B2 - Flat/Cylinder/Doffer Wire",
        "type":                  "Carding",
        "location":              "Carding Section",
        "maintenance_interval":  791,
        "last_maintenance_date": date(2024, 12, 7),
        "next_maintenance_date": date(2027, 2, 7),
    },
    {
        "name":                  "Card B3 - Flat/Cylinder/Doffer Wire",
        "type":                  "Carding",
        "location":              "Carding Section",
        "maintenance_interval":  791,
        "last_maintenance_date": date(2024, 9, 26),
        "next_maintenance_date": date(2026, 11, 26),
    },
    {
        "name":                  "Card B4 - Flat/Cylinder/Doffer Wire",
        "type":                  "Carding",
        "location":              "Carding Section",
        "maintenance_interval":  791,
        "last_maintenance_date": date(2025, 9, 11),
        "next_maintenance_date": date(2027, 9, 11),
    },
    {
        "name":                  "Card B5 - Flat/Cylinder/Doffer Wire",
        "type":                  "Carding",
        "location":              "Carding Section",
        "maintenance_interval":  791,
        "last_maintenance_date": date(2025, 8, 22),
        "next_maintenance_date": date(2026, 10, 22),
    },
    {
        "name":                  "Card B6 - Flat/Cylinder/Doffer Wire",
        "type":                  "Carding",
        "location":              "Carding Section",
        "maintenance_interval":  791,
        "last_maintenance_date": date(2025, 1, 17),
        "next_maintenance_date": date(2027, 3, 17),
    },
]


def seed():
    with app.app_context():
        # Need at least one admin user to satisfy created_by FK
        admin = User.query.filter_by(role="ADMIN").first()
        if not admin:
            print("❌  No ADMIN user found. Run the app once (db.create_all + insert admin) first.")
            return

        seeded = 0
        skipped = 0

        for m in MACHINES:
            exists = Machine.query.filter_by(name=m["name"]).first()
            if exists:
                skipped += 1
                continue

            machine = Machine(
                name=m["name"],
                type=m["type"],
                location=m["location"],
                maintenance_interval=m["maintenance_interval"],
                last_maintenance_date=m["last_maintenance_date"],
                next_maintenance_date=m["next_maintenance_date"],
                status="ACTIVE",
                created_by=admin.id
            )
            db.session.add(machine)
            seeded += 1

        db.session.commit()

        today = date.today()
        print(f"\n✅  Seeding complete!")
        print(f"   Inserted : {seeded} machine(s)")
        print(f"   Skipped  : {skipped} already-existing machine(s)")
        print()

        # Show status summary
        all_m = Machine.query.all()
        overdue = [m for m in all_m if m.next_maintenance_date < today and m.status == "ACTIVE"]
        print(f"   Total machines in DB : {len(all_m)}")
        print(f"   Currently OVERDUE    : {len(overdue)}")
        if overdue:
            print("\n   Overdue machines:")
            for m in sorted(overdue, key=lambda x: x.next_maintenance_date):
                days = (today - m.next_maintenance_date).days
                print(f"     ⚠  [{days:>4}d] {m.name} (due {m.next_maintenance_date})")


if __name__ == "__main__":
    seed()
