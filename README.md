# ERAS — Enterprise Ranking & Admissions System

A production-ready full-stack application for managing residency programme admissions.
Selectors rank applicants sourced **read-only** from Oracle ITS, manage collaborative
workspaces, freeze point-in-time snapshots, and export ranked lists to Excel.

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                          Browser (React)                            │
└───────────────────────────────┬─────────────────────────────────────┘
                                │ HTTPS / JSON
┌───────────────────────────────▼─────────────────────────────────────┐
│              FastAPI Backend  (Python 3.12)                         │
│                                                                     │
│  /api/auth/token   → LDAP authentication → JWT                     │
│  /api/applicants/  → Oracle ITS (read-only)                        │
│  /api/workspaces/  → MariaDB (CRUD)                                │
│  /api/workspaces/{id}/snapshots/  → Oracle snapshot → MariaDB      │
│  /api/workspaces/{id}/rankings/   → MariaDB (CRUD)                 │
│  /api/workspaces/{id}/export/ranked-list → Excel (.xlsx)           │
└────────┬──────────────────────────┬──────────────────────────────────┘
         │                          │
┌────────▼────────┐      ┌─────────▼──────────┐
│   MariaDB 11    │      │  Oracle ITS (RO)   │
│                 │      │                    │
│  workspaces     │      │  eras_applicants   │
│  snapshots      │      │  (read-only view)  │
│  rankings       │      └────────────────────┘
│  audit_logs     │
└─────────────────┘
         │
┌────────▼────────┐
│  LDAP / AD      │
│  (authentication│
│   & groups)     │
└─────────────────┘
```

## Project Structure

```
eras/
├── backend/
│   ├── app/
│   │   ├── config.py             # Settings (env vars via pydantic-settings)
│   │   ├── main.py               # FastAPI app + CORS + router registration
│   │   ├── database/
│   │   │   ├── mariadb.py        # SQLAlchemy engine + session
│   │   │   └── oracle.py         # cx_Oracle read-only connection helper
│   │   ├── models/               # SQLAlchemy ORM models (MariaDB)
│   │   │   ├── workspace.py
│   │   │   ├── snapshot.py
│   │   │   ├── ranking.py
│   │   │   └── audit.py
│   │   ├── schemas/              # Pydantic request/response schemas
│   │   ├── routers/              # FastAPI route handlers
│   │   │   ├── auth.py           # POST /api/auth/token
│   │   │   ├── applicants.py     # GET  /api/applicants/
│   │   │   ├── workspaces.py     # CRUD /api/workspaces/
│   │   │   ├── snapshots.py      # CRUD /api/workspaces/{id}/snapshots/
│   │   │   ├── rankings.py       # PUT  /api/workspaces/{id}/rankings/
│   │   │   └── export.py         # GET  /api/workspaces/{id}/export/ranked-list
│   │   ├── services/
│   │   │   ├── ldap_service.py   # LDAP bind + group-to-role mapping
│   │   │   ├── oracle_service.py # Oracle ITS query helpers (read-only)
│   │   │   └── export_service.py # openpyxl Excel workbook builder
│   │   └── middleware/
│   │       └── auth.py           # JWT creation + dependency helpers
│   ├── alembic/                  # Database migrations
│   │   ├── env.py
│   │   └── versions/
│   │       └── 0001_initial_schema.py
│   ├── tests/
│   │   ├── conftest.py           # SQLite in-memory test DB + TestClient
│   │   ├── test_auth.py
│   │   ├── test_workspaces.py
│   │   ├── test_snapshots.py
│   │   └── test_rankings.py
│   ├── Dockerfile
│   ├── requirements.txt
│   └── requirements-dev.txt
│
├── frontend/
│   ├── src/
│   │   ├── App.tsx               # Router + auth guard
│   │   ├── store/
│   │   │   └── authStore.ts      # Zustand auth state (persisted)
│   │   ├── services/
│   │   │   ├── api.ts            # Axios instance + interceptors
│   │   │   └── erasApi.ts        # Typed API calls
│   │   ├── types/
│   │   │   └── index.ts          # Shared TypeScript interfaces
│   │   ├── pages/
│   │   │   ├── LoginPage.tsx
│   │   │   ├── WorkspacesPage.tsx
│   │   │   ├── WorkspaceDetailPage.tsx  # Rankings + Snapshots + Excel export
│   │   │   └── ApplicantsPage.tsx
│   │   └── components/
│   │       └── Layout.tsx        # Top nav + auth info
│   ├── Dockerfile
│   ├── nginx.conf
│   ├── package.json
│   └── vite.config.ts
│
├── docker-compose.yml
├── .env.example
└── README.md
```

## Core API Endpoints

| Method | Path | Description | Roles |
|--------|------|-------------|-------|
| POST | `/api/auth/token` | LDAP login → JWT | public |
| GET | `/api/health` | Health check | public |
| GET | `/api/applicants/` | List applicants from Oracle ITS | all |
| GET | `/api/applicants/{id}` | Applicant detail | all |
| GET | `/api/workspaces/` | List workspaces | all |
| POST | `/api/workspaces/` | Create workspace | admin, selector |
| GET | `/api/workspaces/{id}` | Get workspace | all |
| PATCH | `/api/workspaces/{id}` | Update workspace | admin, selector |
| DELETE | `/api/workspaces/{id}` | Delete workspace | admin |
| GET | `/api/workspaces/{id}/snapshots/` | List snapshots | all |
| POST | `/api/workspaces/{id}/snapshots/` | Create snapshot (pulls Oracle) | admin, selector |
| GET | `/api/workspaces/{id}/snapshots/{sid}` | Get snapshot detail | all |
| GET | `/api/workspaces/{id}/rankings/` | List ranked applicants | all |
| PUT | `/api/workspaces/{id}/rankings/` | Replace full ranked list | admin, selector |
| GET | `/api/workspaces/{id}/export/ranked-list` | Download Excel workbook | all |

## Database Schema (MariaDB)

```sql
workspaces  (id, name, description, cycle_year, status, created_by, created_at, updated_at)
snapshots   (id, workspace_id FK, label, description, applicant_data JSON, created_by, created_at)
rankings    (id, workspace_id FK, applicant_id, rank, score, notes, ranked_by, created_at, updated_at)
audit_logs  (id, username, action, resource_type, resource_id, detail, extra JSON, ip_address, created_at)
```

## Oracle Read-Only Access Pattern

- A dedicated Oracle account `eras_readonly` is granted SELECT only on `eras_applicants`.
- No DML is ever issued; the Oracle connection is opened per-request via a context manager.
- Applicant data is sourced live for the applicants list and merged into Excel exports.
- Snapshots capture a frozen copy of Oracle data at a point in time and store it in MariaDB JSON.

## LDAP Authentication

1. Service account binds to LDAP to locate the user DN.
2. A second bind with the user's credentials verifies the password.
3. Group membership (`memberOf`) is mapped to application roles:
   - `eras-admins` → `admin`
   - `eras-selectors` → `selector`
   - Authenticated users without either group → `viewer`

## Quick Start

```bash
# 1. Copy and edit configuration
cp .env.example .env

# 2. Start all services
docker compose up --build

# 3. API docs available at
http://localhost:8000/api/docs

# 4. Frontend available at
http://localhost:3000
```

## Running Backend Tests

```bash
cd backend
pip install -r requirements-dev.txt
pytest tests/ -v
```

## Deployment Notes

- Set `SECRET_KEY` to a strong random value (≥ 32 chars) in production.
- The Oracle Instant Client must be available in the backend container (`libaio1`).
- Run `alembic upgrade head` before starting the API (already done in docker-compose).
- Use TLS termination (e.g. Nginx or a load balancer) in front of port 3000/8000.
- Rotate `LDAP_BIND_PASSWORD` and `ORACLE_PASSWORD` via your secrets management system.

