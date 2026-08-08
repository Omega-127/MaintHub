# Contributing to MainHub

Thank you for being part of the MainHub team! This guide covers everything you need to know to contribute effectively — branching, commits, code style, reviews, and more.

---

## 📋 Table of Contents

- [Team Structure](#team-structure)
- [Getting Started](#getting-started)
- [Branch Strategy](#branch-strategy)
- [Commit Messages](#commit-messages)
- [Code Style](#code-style)
- [Pull Request Process](#pull-request-process)
- [Code Review Guidelines](#code-review-guidelines)
- [Testing Requirements](#testing-requirements)
- [Common Commands](#common-commands)
- [Do's and Don'ts](#dos-and-donts)

---

## 👥 Team Structure

| Role | Responsibilities |
|------|-----------------|
| **Backend Lead** | Flask APIs, database models, scheduler |
| **Frontend Lead** | Flutter screens, state management, UI |
| **Database/DevOps** | MySQL schema, Docker, deployment |
| **All Members** | Code reviews, testing, documentation |

---

## 🚀 Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/your-org/MaintHub.git
cd MaintHub
```

### 2. Set Up Your Environment

**Backend:**
```bash
cd mainthub-backend
python -m venv venv
venv\Scripts\activate        # Windows
source venv/bin/activate     # Mac/Linux
pip install -r requirements.txt
cp .env.example .env
# Edit .env with your credentials
```

**Frontend:**
```bash
cd mainthub-app
flutter pub get
```

**Database:**
```bash
# From repo root
docker-compose up -d mysql
```

### 3. Verify Everything Works

```bash
# Backend should start with no errors
cd mainthub-backend && python run.py

# Flutter should build with no errors
cd mainthub-app && flutter run
```

---

## 🌿 Branch Strategy

We follow **Git Flow** — a clean, industry-standard branching model.

### Main Branches

| Branch | Purpose | Who pushes |
|--------|---------|-----------|
| `main` | Production-ready code | Only via PR after review |
| `develop` | Integration branch — latest working code | Only via PR |

### Supporting Branches

Always branch off `develop`, never off `main`.

```
feature/    → New features
bugfix/     → Bug fixes
hotfix/     → Critical production fixes (branch off main)
docs/       → Documentation only changes
```

### Branch Naming Convention

```bash
# Pattern: <type>/<short-description>

feature/machine-search
feature/notification-system
feature/dashboard-charts

bugfix/login-token-expiry
bugfix/scheduler-not-triggering

docs/api-specification
docs/setup-guide

hotfix/database-connection-crash
```

### Creating a Feature Branch

```bash
# Always start from latest develop
git checkout develop
git pull origin develop

# Create your branch
git checkout -b feature/your-feature-name

# Work on your feature...
# When done, push
git push origin feature/your-feature-name

# Then create a Pull Request on GitHub → develop
```

---

## 💬 Commit Messages

We follow the **Conventional Commits** standard. Clear commit messages help the team understand what changed and why.

### Format

```
<type>(<scope>): <short description>

<body — optional, explains why not what>

<footer — optional, references issues>
```

### Types

| Type | When to Use |
|------|------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `style` | Formatting, no logic change |
| `refactor` | Code restructure, no feature/fix |
| `test` | Adding or updating tests |
| `chore` | Build process, dependencies, config |

### Scopes (optional but helpful)

`auth`, `machines`, `maintenance`, `dashboard`, `notifications`, `scheduler`, `db`, `ui`, `api`

### Examples

```bash
# Good commit messages
git commit -m "feat(machines): add search filter by type and location"
git commit -m "fix(auth): resolve JWT token expiry not refreshing"
git commit -m "feat(dashboard): add overdue machine count card"
git commit -m "fix(scheduler): prevent duplicate notifications for same machine"
git commit -m "docs(api): add request/response examples for machines endpoint"
git commit -m "chore(deps): upgrade Flask to 3.0.3"
git commit -m "test(auth): add unit tests for login validation"

# Bad commit messages (avoid these)
git commit -m "fix bug"
git commit -m "changes"
git commit -m "wip"
git commit -m "stuff"
git commit -m "update"
```

### Commit Discipline

- **One logical change per commit** — don't bundle unrelated changes
- **Commit often** — small commits are easier to review and revert
- **Never commit broken code** — all commits should at least compile
- **Push daily** — even work-in-progress on your feature branch

---

## 🎨 Code Style

### Python (Backend)

Follow **PEP 8** with these specifics:

```python
# ✅ Good — clear, typed, documented
def calculate_next_date(last_date: date, interval_days: int) -> date:
    """Calculate next maintenance date."""
    return last_date + timedelta(days=interval_days)

# ❌ Bad — no types, unclear name
def calc(d, i):
    return d + timedelta(days=i)
```

**Rules:**
- 4 spaces indentation (no tabs)
- Max line length: 100 characters
- Type hints on all function parameters and return types
- Docstrings on all functions and classes
- No unused imports
- Use `f-strings` not `.format()` or `%`

**Format before committing:**
```bash
# Auto-format
black app/

# Check style
pylint app/
```

### Dart/Flutter (Frontend)

Follow official **Dart style guide**:

```dart
// ✅ Good — descriptive names, const where possible
class MachineCard extends StatelessWidget {
  final Machine machine;
  const MachineCard({super.key, required this.machine});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(machine.name),
        subtitle: Text(machine.type),
      ),
    );
  }
}

// ❌ Bad — abbreviations, no const
class MC extends StatelessWidget {
  var m;
  MC(this.m);
  ...
}
```

**Rules:**
- Use `const` constructors wherever possible
- Prefer `final` over `var`
- Widget files: one widget per file
- File names: `snake_case.dart`
- Class names: `PascalCase`
- Variable names: `camelCase`

**Format before committing:**
```bash
# Auto-format
dart format lib/

# Check style
dart analyze lib/
```

### SQL (Database)

```sql
-- ✅ Good — uppercase keywords, clear naming
SELECT m.name, m.next_maintenance_date
FROM machines m
WHERE m.status = 'ACTIVE'
  AND m.next_maintenance_date <= CURDATE()
ORDER BY m.next_maintenance_date ASC;

-- ❌ Bad
select name,next_maintenance_date from machines where status='ACTIVE'
```

---

## 🔄 Pull Request Process

### Before Creating a PR

- [ ] Code runs without errors locally
- [ ] Tests pass (`pytest` for backend, `flutter test` for frontend)
- [ ] No debug statements or `print()` left in code
- [ ] No `.env` or secrets committed
- [ ] Code formatted (`black` / `dart format`)
- [ ] Self-reviewed your own diff on GitHub

### Creating the PR

1. Push your branch:
   ```bash
   git push origin feature/your-feature-name
   ```

2. Go to GitHub → **New Pull Request**

3. Set:
   - **Base:** `develop`
   - **Compare:** `feature/your-feature-name`

4. Fill in the PR template:

```markdown
## What does this PR do?
Brief description of the change.

## Type of change
- [ ] New feature
- [ ] Bug fix
- [ ] Documentation
- [ ] Refactor

## How to test
1. Start the backend: `python run.py`
2. Login with admin@mainthub.com / admin123
3. Navigate to Machines → Add Machine
4. Verify machine is created and next date is calculated

## Screenshots (if UI change)
[paste screenshots here]

## Checklist
- [ ] Code runs locally
- [ ] Tests pass
- [ ] No secrets committed
- [ ] Self-reviewed
```

### PR Rules

- **Minimum 1 approval** required before merging
- **No self-merging** — always get a teammate to review
- **Address all review comments** before merging
- **Keep PRs small** — large PRs are hard to review (aim for < 400 lines changed)
- **Delete branch** after merging

---

## 👀 Code Review Guidelines

### As a Reviewer

**Do:**
- Review within 24 hours of being assigned
- Be specific — "line 42: this should be `date.today()` not `datetime.now()`"
- Explain why, not just what — "Use `date.today()` here because we only need the date, not time"
- Approve once all major issues are resolved
- Use GitHub suggestion feature for small fixes

**Don't:**
- Be vague — "this is wrong" without explanation
- Block on style preferences — use linters for that
- Approve code you don't understand
- Leave reviews pending for more than 24 hours

### Review Labels

Use these in your comments:

```
[blocker]   → Must fix before merge
[question]  → Need clarification
[suggestion]→ Optional improvement
[nit]       → Minor style point, non-blocking
```

Example:
```
[blocker] This will crash if machine.last_maintenance_date is None.
          Add a null check before calling + timedelta().

[suggestion] Consider extracting this into a separate helper function
             since the same logic appears in scheduler.py.

[nit] Missing trailing newline at end of file.
```

---

## 🧪 Testing Requirements

### Backend — Pytest

Every new feature or bug fix must have tests.

```bash
# Run all tests
cd mainthub-backend
pytest

# Run with coverage report
pytest --cov=app tests/

# Run specific test file
pytest tests/test_auth.py -v
```

**Minimum coverage: 70%**

**Test file naming:** `test_<module>.py`

```python
# tests/test_machines.py
def test_create_machine_success(client, admin_token):
    """Admin can create a machine."""
    response = client.post('/api/machines/', 
        json={...},
        headers={'Authorization': f'Bearer {admin_token}'}
    )
    assert response.status_code == 201

def test_create_machine_unauthorized(client, tech_token):
    """Technician cannot create a machine."""
    response = client.post('/api/machines/',
        json={...},
        headers={'Authorization': f'Bearer {tech_token}'}
    )
    assert response.status_code == 403
```

### Frontend — Flutter Test

```bash
# Run all tests
cd mainthub-app
flutter test

# Run specific test
flutter test test/providers/auth_provider_test.dart
```

---

## ⚡ Common Commands

### Git

```bash
# Update your branch with latest develop
git checkout develop
git pull origin develop
git checkout feature/your-branch
git rebase develop

# Undo last commit (keep changes)
git reset --soft HEAD~1

# Discard all local changes
git checkout .

# See what changed
git diff
git status
git log --oneline -10
```

### Backend

```bash
cd mainthub-backend
venv\Scripts\activate          # activate venv

python run.py                  # start server
pytest                         # run tests
pytest --cov=app tests/        # tests with coverage
black app/                     # format code
pylint app/                    # lint check
```

### Frontend

```bash
cd mainthub-app
flutter pub get                # install dependencies
flutter run                    # run on emulator
flutter test                   # run tests
dart format lib/               # format code
dart analyze lib/              # lint check
flutter build apk              # build Android APK
```

### Docker (Database)

```bash
# From MaintHub/ root
docker-compose up -d mysql     # start MySQL only
docker-compose down            # stop all
docker-compose down -v         # stop + delete data (full reset)
docker logs mainthub-mysql     # view DB logs
```

---

## ✅ Do's and Don'ts

### Do's ✅

- **Pull before you push** — always `git pull origin develop` before starting new work
- **Write descriptive variable names** — `nextMaintenanceDate` not `nmd`
- **Handle errors** — always handle API errors gracefully in Flutter
- **Comment complex logic** — especially the scheduler and date calculations
- **Test on a real device** — at least once before merging UI changes
- **Review your own PR first** — check GitHub diff before requesting reviews
- **Ask early** — if stuck for more than 30 mins, ask the team

### Don'ts ❌

- **Don't commit `.env`** — never commit real credentials
- **Don't push to `main` or `develop` directly** — always use PRs
- **Don't merge your own PR** — get a teammate to review
- **Don't leave `print()` statements** — remove debug output before PR
- **Don't hardcode credentials** — always use `.env` variables
- **Don't ignore failing tests** — fix them before pushing
- **Don't make huge PRs** — split large features into smaller chunks

---

## 🆘 Need Help?

1. **Check the docs first** — `docs/` folder has guides for everything
2. **Search existing issues** — someone may have faced the same problem
3. **Ask in team chat** — Slack/WhatsApp/Discord
4. **Create a GitHub issue** — for bugs or feature discussions
5. **Tag a teammate on PR** — for urgent reviews

---

## 📞 Contacts

| Issue | Contact |
|-------|---------|
| Backend/API | Backend Lead |
| Flutter/UI | Frontend Lead |
| Database/Docker | DevOps Lead |
| General | Team Chat |

---

*Last updated: August 2026*
*MainHub Team*
