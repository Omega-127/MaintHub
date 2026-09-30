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

# ── Machine seed data ─────────────────────────────────────────────────────────
MACHINES = [
    # ── BLOWROOM Department ───────────────────────────────────────────────────
    {
        "name":                  "Bale Plucking Rolls",
        "type":                  "Blowroom",
        "department":            "BLOWROOM",
        "location":              "Blowroom Section",
        "maintenance_interval":  1826,                  # ~5 years
        "last_maintenance_date": date(2023, 8, 2),
        "next_maintenance_date": date(2028, 8, 2),
    },
    {
        "name":                  "Bale Plucker Lifting Belt",
        "type":                  "Blowroom",
        "department":            "BLOWROOM",
        "location":              "Blowroom Section",
        "maintenance_interval":  1826,
        "last_maintenance_date": date(2021, 5, 25),
        "next_maintenance_date": date(2026, 5, 25),
    },
    {
        "name":                  "Bale Plucker Up & Down Cam Roll Bearing",
        "type":                  "Blowroom",
        "department":            "BLOWROOM",
        "location":              "Blowroom Section",
        "maintenance_interval":  730,                   # ~2 years
        "last_maintenance_date": date(2024, 3, 2),
        "next_maintenance_date": date(2026, 3, 2),
    },
    {
        "name":                  "Chute Feed Opener Roll Nitrate (A1-A4, B1-B4)",
        "type":                  "Blowroom",
        "department":            "BLOWROOM",
        "location":              "Blowroom Section",
        "maintenance_interval":  730,
        "last_maintenance_date": date(2023, 9, 6),
        "next_maintenance_date": date(2025, 9, 6),
    },
    {
        "name":                  "Unimix Beater Wire",
        "type":                  "Blowroom",
        "department":            "BLOWROOM",
        "location":              "Blowroom Section",
        "maintenance_interval":  912,                   # ~2.5 years
        "last_maintenance_date": date(2025, 12, 17),
        "next_maintenance_date": date(2028, 6, 17),
    },
    {
        "name":                  "Unimix Feed Roll Bearing",
        "type":                  "Blowroom",
        "department":            "BLOWROOM",
        "location":              "Blowroom Section",
        "maintenance_interval":  1826,
        "last_maintenance_date": date(2018, 6, 18),
        "next_maintenance_date": date(2023, 6, 18),    # OVERDUE
    },
    {
        "name":                  "Unimix Gear Index",
        "type":                  "Blowroom",
        "department":            "BLOWROOM",
        "location":              "Blowroom Section",
        "maintenance_interval":  730,
        "last_maintenance_date": date(2025, 1, 17),
        "next_maintenance_date": date(2027, 1, 17),
    },
    {
        "name":                  "Flexiclean Beater Wire",
        "type":                  "Blowroom",
        "department":            "BLOWROOM",
        "location":              "Blowroom Section",
        "maintenance_interval":  912,
        "last_maintenance_date": date(2024, 3, 16),
        "next_maintenance_date": date(2026, 3, 16),
    },
    {
        "name":                  "Flexiclean Feed Roll Bearing",
        "type":                  "Blowroom",
        "department":            "BLOWROOM",
        "location":              "Blowroom Section",
        "maintenance_interval":  1826,
        "last_maintenance_date": date(2018, 6, 18),
        "next_maintenance_date": date(2023, 6, 18),    # OVERDUE
    },
    {
        "name":                  "Flexiclean Fluted Roll (Rubber)",
        "type":                  "Blowroom",
        "department":            "BLOWROOM",
        "location":              "Blowroom Section",
        "maintenance_interval":  730,
        "last_maintenance_date": date(2024, 3, 2),
        "next_maintenance_date": date(2026, 3, 2),
    },
    {
        "name":                  "Condensor Cage Drum",
        "type":                  "Blowroom",
        "department":            "BLOWROOM",
        "location":              "Blowroom Section",
        "maintenance_interval":  1826,
        "last_maintenance_date": date(2019, 5, 2),
        "next_maintenance_date": date(2024, 5, 2),     # OVERDUE
    },
    {
        "name":                  "Primer i-Qube (CCS) LED/UV Tubes",
        "type":                  "Blowroom",
        "department":            "BLOWROOM",
        "location":              "Blowroom Section",
        "maintenance_interval":  730,
        "last_maintenance_date": date(2025, 2, 1),
        "next_maintenance_date": date(2027, 2, 1),
    },
    # ── BLOWROOM: Carding Machines (Flat/Cylinder/Doffer Wire Overhauling) ───
    {
        "name":                  "Card A1 - Flat/Cylinder/Doffer Wire",
        "type":                  "Carding",
        "department":            "BLOWROOM",
        "location":              "Carding Section",
        "maintenance_interval":  791,
        "last_maintenance_date": date(2025, 2, 2),
        "next_maintenance_date": date(2027, 4, 2),
    },
    {
        "name":                  "Card A2 - Flat/Cylinder/Doffer Wire",
        "type":                  "Carding",
        "department":            "BLOWROOM",
        "location":              "Carding Section",
        "maintenance_interval":  791,
        "last_maintenance_date": date(2024, 9, 6),
        "next_maintenance_date": date(2026, 11, 6),
    },
    {
        "name":                  "Card A3 - Flat/Cylinder/Doffer Wire",
        "type":                  "Carding",
        "department":            "BLOWROOM",
        "location":              "Carding Section",
        "maintenance_interval":  791,
        "last_maintenance_date": date(2025, 3, 7),
        "next_maintenance_date": date(2027, 5, 7),
    },
    {
        "name":                  "Card A4 - Flat/Cylinder/Doffer Wire",
        "type":                  "Carding",
        "department":            "BLOWROOM",
        "location":              "Carding Section",
        "maintenance_interval":  791,
        "last_maintenance_date": date(2024, 5, 18),
        "next_maintenance_date": date(2026, 7, 18),
    },
    {
        "name":                  "Card A5 - Flat/Cylinder/Doffer Wire",
        "type":                  "Carding",
        "department":            "BLOWROOM",
        "location":              "Carding Section",
        "maintenance_interval":  791,
        "last_maintenance_date": date(2024, 4, 16),
        "next_maintenance_date": date(2026, 6, 16),
    },
    {
        "name":                  "Card A6 - Flat/Cylinder/Doffer Wire",
        "type":                  "Carding",
        "department":            "BLOWROOM",
        "location":              "Carding Section",
        "maintenance_interval":  791,
        "last_maintenance_date": date(2024, 12, 16),
        "next_maintenance_date": date(2027, 2, 16),
    },
    {
        "name":                  "Card B1 - Flat/Cylinder/Doffer Wire",
        "type":                  "Carding",
        "department":            "BLOWROOM",
        "location":              "Carding Section",
        "maintenance_interval":  791,
        "last_maintenance_date": date(2025, 6, 19),
        "next_maintenance_date": date(2027, 8, 19),
    },
    {
        "name":                  "Card B2 - Flat/Cylinder/Doffer Wire",
        "type":                  "Carding",
        "department":            "BLOWROOM",
        "location":              "Carding Section",
        "maintenance_interval":  791,
        "last_maintenance_date": date(2024, 12, 7),
        "next_maintenance_date": date(2027, 2, 7),
    },
    {
        "name":                  "Card B3 - Flat/Cylinder/Doffer Wire",
        "type":                  "Carding",
        "department":            "BLOWROOM",
        "location":              "Carding Section",
        "maintenance_interval":  791,
        "last_maintenance_date": date(2024, 9, 26),
        "next_maintenance_date": date(2026, 11, 26),
    },
    {
        "name":                  "Card B4 - Flat/Cylinder/Doffer Wire",
        "type":                  "Carding",
        "department":            "BLOWROOM",
        "location":              "Carding Section",
        "maintenance_interval":  791,
        "last_maintenance_date": date(2025, 9, 11),
        "next_maintenance_date": date(2027, 9, 11),
    },
    {
        "name":                  "Card B5 - Flat/Cylinder/Doffer Wire",
        "type":                  "Carding",
        "department":            "BLOWROOM",
        "location":              "Carding Section",
        "maintenance_interval":  791,
        "last_maintenance_date": date(2025, 8, 22),
        "next_maintenance_date": date(2026, 10, 22),
    },
    {
        "name":                  "Card B6 - Flat/Cylinder/Doffer Wire",
        "type":                  "Carding",
        "department":            "BLOWROOM",
        "location":              "Carding Section",
        "maintenance_interval":  791,
        "last_maintenance_date": date(2025, 1, 17),
        "next_maintenance_date": date(2027, 3, 17),
    },

    # ── COMBER Department (Comber LK-64, sourced from comber_schedules.xlsx) ─
    # 1. Top Comb change — Schedule: 600 tons (2 years) = 730 days
    #    Last changed: Cbr 1 = 09.08.26, Cbr 2 = 08.08.26, Cbr 3 = 06.09.26,
    #    Cbr 4 & 5 = same as above (06.09.26)
    #    We store per-machine records (one per comber head, 5 total)
    {
        "name":                  "Comber 1 - Top Comb Change",
        "type":                  "Comber",
        "department":            "COMBER",
        "location":              "Comber Section",
        "maintenance_interval":  730,                   # ~2 years / 600 tons
        "last_maintenance_date": date(2026, 8, 9),
        "next_maintenance_date": date(2028, 8, 9),
    },
    {
        "name":                  "Comber 2 - Top Comb Change",
        "type":                  "Comber",
        "department":            "COMBER",
        "location":              "Comber Section",
        "maintenance_interval":  730,
        "last_maintenance_date": date(2026, 8, 8),
        "next_maintenance_date": date(2028, 8, 8),
    },
    {
        "name":                  "Comber 3 - Top Comb Change",
        "type":                  "Comber",
        "department":            "COMBER",
        "location":              "Comber Section",
        "maintenance_interval":  730,
        "last_maintenance_date": date(2026, 9, 6),
        "next_maintenance_date": date(2028, 9, 6),
    },
    {
        "name":                  "Comber 4 - Top Comb Change",
        "type":                  "Comber",
        "department":            "COMBER",
        "location":              "Comber Section",
        "maintenance_interval":  730,
        "last_maintenance_date": date(2026, 9, 6),
        "next_maintenance_date": date(2028, 9, 6),
    },
    {
        "name":                  "Comber 5 - Top Comb Change",
        "type":                  "Comber",
        "department":            "COMBER",
        "location":              "Comber Section",
        "maintenance_interval":  730,
        "last_maintenance_date": date(2026, 9, 6),
        "next_maintenance_date": date(2028, 9, 6),
    },
    # 2. Half Lap Brush Change — Schedule: 1000 tons (3 years) = 1095 days
    #    Last changed: Cbr1=01.09.24, Cbr2=08.09.24, Cbr3=29.08.24, Cbr4=14.09.24, Cbr5=16.09.24
    {
        "name":                  "Comber 1 - Half Lap Brush Change",
        "type":                  "Comber",
        "department":            "COMBER",
        "location":              "Comber Section",
        "maintenance_interval":  1095,                  # ~3 years / 1000 tons
        "last_maintenance_date": date(2024, 9, 1),
        "next_maintenance_date": date(2027, 9, 1),
    },
    {
        "name":                  "Comber 2 - Half Lap Brush Change",
        "type":                  "Comber",
        "department":            "COMBER",
        "location":              "Comber Section",
        "maintenance_interval":  1095,
        "last_maintenance_date": date(2024, 9, 8),
        "next_maintenance_date": date(2027, 9, 8),
    },
    {
        "name":                  "Comber 3 - Half Lap Brush Change",
        "type":                  "Comber",
        "department":            "COMBER",
        "location":              "Comber Section",
        "maintenance_interval":  1095,
        "last_maintenance_date": date(2024, 8, 29),
        "next_maintenance_date": date(2027, 8, 29),
    },
    {
        "name":                  "Comber 4 - Half Lap Brush Change",
        "type":                  "Comber",
        "department":            "COMBER",
        "location":              "Comber Section",
        "maintenance_interval":  1095,
        "last_maintenance_date": date(2024, 9, 14),
        "next_maintenance_date": date(2027, 9, 14),
    },
    {
        "name":                  "Comber 5 - Half Lap Brush Change",
        "type":                  "Comber",
        "department":            "COMBER",
        "location":              "Comber Section",
        "maintenance_interval":  1095,
        "last_maintenance_date": date(2024, 9, 16),
        "next_maintenance_date": date(2027, 9, 16),
    },
    # 3. Half Lap (Unicomb) Change — Schedule: 1500 tons (5 years) = 1826 days
    #    Last changed: 15.03.13 (all combers)
    {
        "name":                  "Comber 1 - Half Lap (Unicomb) Change",
        "type":                  "Comber",
        "department":            "COMBER",
        "location":              "Comber Section",
        "maintenance_interval":  1826,                  # ~5 years / 1500 tons
        "last_maintenance_date": date(2013, 3, 15),
        "next_maintenance_date": date(2018, 3, 15),    # OVERDUE — needs replacement
    },
    {
        "name":                  "Comber 2 - Half Lap (Unicomb) Change",
        "type":                  "Comber",
        "department":            "COMBER",
        "location":              "Comber Section",
        "maintenance_interval":  1826,
        "last_maintenance_date": date(2013, 3, 15),
        "next_maintenance_date": date(2018, 3, 15),    # OVERDUE
    },
    {
        "name":                  "Comber 3 - Half Lap (Unicomb) Change",
        "type":                  "Comber",
        "department":            "COMBER",
        "location":              "Comber Section",
        "maintenance_interval":  1826,
        "last_maintenance_date": date(2013, 3, 15),
        "next_maintenance_date": date(2018, 3, 15),    # OVERDUE
    },
    {
        "name":                  "Comber 4 - Half Lap (Unicomb) Change",
        "type":                  "Comber",
        "department":            "COMBER",
        "location":              "Comber Section",
        "maintenance_interval":  1826,
        "last_maintenance_date": date(2013, 3, 15),
        "next_maintenance_date": date(2018, 3, 15),    # OVERDUE
    },
    # 4. Half Lap Brush Setting — Schedule: set 1 mm max (6-monthly = 180 days)
    #    Last set: 20.06.26 (all combers)
    {
        "name":                  "Comber 1 - Half Lap Brush Setting",
        "type":                  "Comber",
        "department":            "COMBER",
        "location":              "Comber Section",
        "maintenance_interval":  180,                   # ~6 months
        "last_maintenance_date": date(2026, 6, 20),
        "next_maintenance_date": date(2026, 12, 17),
    },
    {
        "name":                  "Comber 2 - Half Lap Brush Setting",
        "type":                  "Comber",
        "department":            "COMBER",
        "location":              "Comber Section",
        "maintenance_interval":  180,
        "last_maintenance_date": date(2026, 6, 20),
        "next_maintenance_date": date(2026, 12, 17),
    },
    {
        "name":                  "Comber 3 - Half Lap Brush Setting",
        "type":                  "Comber",
        "department":            "COMBER",
        "location":              "Comber Section",
        "maintenance_interval":  180,
        "last_maintenance_date": date(2026, 6, 20),
        "next_maintenance_date": date(2026, 12, 17),
    },
    {
        "name":                  "Comber 4 - Half Lap Brush Setting",
        "type":                  "Comber",
        "department":            "COMBER",
        "location":              "Comber Section",
        "maintenance_interval":  180,
        "last_maintenance_date": date(2026, 6, 20),
        "next_maintenance_date": date(2026, 12, 17),
    },
    {
        "name":                  "Comber 5 - Half Lap Brush Setting",
        "type":                  "Comber",
        "department":            "COMBER",
        "location":              "Comber Section",
        "maintenance_interval":  180,
        "last_maintenance_date": date(2026, 6, 20),
        "next_maintenance_date": date(2026, 12, 17),
    },
    # 5. Basic Settings — Schedule: 6 months = 180 days
    #    Last done: Aug-26 (all combers)
    {
        "name":                  "Comber 1 - Basic Settings",
        "type":                  "Comber",
        "department":            "COMBER",
        "location":              "Comber Section",
        "maintenance_interval":  180,                   # 6 months
        "last_maintenance_date": date(2026, 8, 1),
        "next_maintenance_date": date(2027, 1, 28),
    },
    {
        "name":                  "Comber 2 - Basic Settings",
        "type":                  "Comber",
        "department":            "COMBER",
        "location":              "Comber Section",
        "maintenance_interval":  180,
        "last_maintenance_date": date(2026, 8, 1),
        "next_maintenance_date": date(2027, 1, 28),
    },
    {
        "name":                  "Comber 3 - Basic Settings",
        "type":                  "Comber",
        "department":            "COMBER",
        "location":              "Comber Section",
        "maintenance_interval":  180,
        "last_maintenance_date": date(2026, 8, 1),
        "next_maintenance_date": date(2027, 1, 28),
    },
    {
        "name":                  "Comber 4 - Basic Settings",
        "type":                  "Comber",
        "department":            "COMBER",
        "location":              "Comber Section",
        "maintenance_interval":  180,
        "last_maintenance_date": date(2026, 8, 1),
        "next_maintenance_date": date(2027, 1, 28),
    },
    {
        "name":                  "Comber 5 - Basic Settings",
        "type":                  "Comber",
        "department":            "COMBER",
        "location":              "Comber Section",
        "maintenance_interval":  180,
        "last_maintenance_date": date(2026, 8, 1),
        "next_maintenance_date": date(2027, 1, 28),
    },
    # 6. Gear Box Oil Change — Kluber 150 | Schedule: 200 tons (~7 months = 213 days)
    #    Last changed: 12.07.26 (all combers 1-5)
    {
        "name":                  "Comber 1-5 - Gear Box Oil Change",
        "type":                  "Comber",
        "department":            "COMBER",
        "location":              "Comber Section",
        "maintenance_interval":  213,                   # ~7 months / 200 tons
        "last_maintenance_date": date(2026, 7, 12),
        "next_maintenance_date": date(2027, 2, 10),
    },
    # 7. Servo Motor Gear Box Oil Change — 68 no. / 800 ml | Schedule: 4 months = 122 days
    #    Last changed: 02.12.25 (all combers 1-5)
    {
        "name":                  "Comber 1-5 - Servo Motor Gear Box Oil Change",
        "type":                  "Comber",
        "department":            "COMBER",
        "location":              "Comber Section",
        "maintenance_interval":  122,                   # 4 months
        "last_maintenance_date": date(2025, 12, 2),
        "next_maintenance_date": date(2026, 4, 3),     # OVERDUE
    },
    # 8. Unicomb Petrol Wash — Schedule: 4 months = 122 days
    #    Last done: 01.08.26 (all combers 1-5)
    {
        "name":                  "Comber 1-5 - Unicomb Petrol Wash",
        "type":                  "Comber",
        "department":            "COMBER",
        "location":              "Comber Section",
        "maintenance_interval":  122,                   # 4 months
        "last_maintenance_date": date(2026, 8, 1),
        "next_maintenance_date": date(2026, 12, 1),
    },
    # NOTE: Nipper Pin Changed is intentionally excluded as per user instructions.
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
                department=m["department"],
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

        # Show status summary by department
        all_m = Machine.query.all()
        blowroom_m = [m for m in all_m if m.department == "BLOWROOM"]
        comber_m   = [m for m in all_m if m.department == "COMBER"]
        overdue    = [m for m in all_m if m.next_maintenance_date < today and m.status == "ACTIVE"]

        print(f"   Total machines in DB  : {len(all_m)}")
        print(f"   BLOWROOM machines     : {len(blowroom_m)}")
        print(f"   COMBER machines       : {len(comber_m)}")
        print(f"   Currently OVERDUE     : {len(overdue)}")
        if overdue:
            print("\n   Overdue machines:")
            for m in sorted(overdue, key=lambda x: x.next_maintenance_date):
                days = (today - m.next_maintenance_date).days
                print(f"     ⚠  [{days:>4}d] [{m.department}] {m.name} (due {m.next_maintenance_date})")


if __name__ == "__main__":
    seed()
