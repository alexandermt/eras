# ERAS — Enterprise Ranking & Admissions System

ERAS is a production-ready admissions ranking platform built on
**RAD Studio 13 + UniGUI + UniDAC + FastReport + Python4Delphi**.

> **ERAS does NOT update applicant status and never writes to Oracle ITS.**
> Selectors export ranked lists to Excel/PDF and update source systems manually.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        Browser (ExtJS / UniGUI)                 │
└────────────────────────────┬────────────────────────────────────┘
                             │ HTTP (stateful UniGUI session)
┌────────────────────────────▼────────────────────────────────────┐
│          Windows Service  ─  IIS  ─  ERAS.exe (UniGUI)          │
│                                                                  │
│  Forms\        DataModules\       Core\         Python\          │
│  uMainForm     uDMMain (P4D)      uAppConfig    ldap_auth.py     │
│  uLoginForm    uDMOracle (RO)     uSessionMgr   oracle_queries   │
│  uWorkspace    uDMWorkspace       uAuditLogger  snapshot_utils   │
│  uSnapshot     uDMSnapshot        uJSONHelper   scoring.py       │
│  uRanking      uDMRankings        uConstants                     │
│  uExport       uDMAudit                                          │
│                                                                  │
│  Reports\      SQL\               Deploy\                        │
│  RankingList   001_schema.sql     config.ini.template            │
│  ApplicantSumm 002_seed_data.sql  install_service.bat            │
│  AuditLog                                                        │
└───────────────┬───────────────────────┬─────────────────────────┘
                │ UniDAC (read-only)     │ UniDAC (read-write)
   ┌────────────▼──────────┐   ┌────────▼────────────────┐
   │  Oracle ITS (source)  │   │  MariaDB (ERAS data)     │
   │  its_applicants       │   │  users, workspaces       │
   │  its_programme_choices│   │  snapshots, rankings     │
   └───────────────────────┘   │  audit_logs              │
                               └─────────────────────────┘
```

---

## Technology Stack

| Layer              | Tool                                  |
|--------------------|---------------------------------------|
| IDE                | RAD Studio 13                         |
| Web UI             | UniGUI (ExtJS rendered in browser)    |
| Database           | UniDAC (DevArt) — Oracle RO + MariaDB RW |
| Reports & Export   | FastReport (XLSX + PDF)               |
| LDAP Auth + Python | Python4Delphi (P4D) + ldap3           |
| Deployment         | Windows Service + IIS                 |

---

## Prerequisites

- RAD Studio 13 (Delphi)
- UniGUI licence (FMSoft)
- UniDAC licence (DevArt) — Oracle + MySQL providers
- FastReport VCL
- Python4Delphi (P4D)
- Python 3.11+ (64-bit, matching Win64 target)
- Windows Server 2019/2022 (deployment) or Windows 10/11 (development)
- MariaDB 10.6+ (ERAS database, schema already executed)
- Oracle client / Oracle Instant Client (for UniDAC Oracle provider)

---

## Getting Started

### 1. Clone the repository
```bash
git clone https://github.com/alexandermt/eras.git
cd eras
```

### 2. Open project in RAD Studio 13
```
File → Open → ERAS\ERAS.dproj
```

### 3. Install Python dependencies
```bash
pip install -r ERAS\Python\requirements.txt
```

### 4. Configure the application
```bash
copy ERAS\Deploy\config.ini.template ERAS\Deploy\config.ini
# Edit config.ini and fill in real credentials
```
See [Configuration Reference](#configuration-reference) below.

### 5. Run the MariaDB schema (if not already applied)
```sql
-- Already executed on 2026-03-03, kept for reference / fresh deployments
mysql -u root -p eras < ERAS\SQL\001_create_schema.sql
mysql -u root -p eras < ERAS\SQL\002_seed_data.sql
```

### 6. Build and run in development
Press **F9** in RAD Studio. The UniGUI application starts on port 8077 by default.

### 7. Install as Windows Service (production)
```bat
ERAS\Deploy\install_service.bat
net start ERAS
```

---

## Configuration Reference

`config.ini` (copied from `Deploy\config.ini.template`):

| Section     | Key              | Description                                     |
|-------------|------------------|-------------------------------------------------|
| Database    | MariaDBHost      | MariaDB server hostname or IP                   |
| Database    | MariaDBPort      | MariaDB port (default 3306)                     |
| Database    | MariaDBDatabase  | Schema name (default: `eras`)                   |
| Database    | MariaDBUser      | MariaDB username                                |
| Database    | MariaDBPassword  | MariaDB password                                |
| Oracle      | OracleTNS        | Oracle TNS string `host:port/service`           |
| Oracle      | OracleUser       | Oracle read-only username                       |
| Oracle      | OraclePassword   | Oracle read-only password                       |
| Oracle      | OracleDirect     | Use UniDAC Direct mode (`True`/`False`)         |
| LDAP        | LDAPHost         | LDAP URL e.g. `ldap://ad.corp.example.com`      |
| LDAP        | LDAPDomain       | NetBIOS domain e.g. `CORP`                      |
| LDAP        | LDAPBaseDN       | Base DN e.g. `DC=corp,DC=example,DC=com`        |
| Application | SessionTimeout   | Session idle timeout in minutes (default 480)   |
| Application | SnapshotMode     | Always `True` — all ranking done on snapshots   |
| Application | ReportsPath      | Path to `.fr3` report templates                 |
| Application | PythonPath       | Path to Python environment / scripts directory  |
| Application | LogPath          | Path for application log files                  |

---

## Database Schema

| Table                | Purpose                                           |
|----------------------|---------------------------------------------------|
| `users`              | ERAS users (populated on first LDAP login)        |
| `workspaces`         | Admissions workspaces (per programme/cycle)       |
| `workspace_members`  | User access to workspaces (viewer/editor/owner)   |
| `snapshots`          | Frozen copies of Oracle applicant data            |
| `snapshot_applicants`| Applicant JSON data captured from Oracle ITS      |
| `rankings`           | Rank positions, scores, status per applicant      |
| `audit_logs`         | Full audit trail of all mutations                 |

---

## Key Workflows

```
Login (LDAP)
  └─► Workspace list
        └─► Open Workspace → Snapshot list
              ├─► New Snapshot (pulls from Oracle ITS → frozen in MariaDB)
              ├─► Freeze Snapshot (makes rankings read-only)
              └─► Open Rankings
                    ├─► Edit rank positions, scores, status, notes
                    ├─► Save Changes (checks snapshot not frozen)
                    └─► Export → Excel XLSX or PDF (FastReport)
```

---

## Security Notes

- **Oracle is strictly read-only.** UniDAC connection uses `ProviderName='Oracle'` with
  `ALTER SESSION SET TRANSACTION READ ONLY` enforced on every connect via
  `TDMMain.EnsureOracleReadOnly`. No INSERT/UPDATE/DELETE ever targets Oracle.
- **LDAP authentication** is handled via `Python4Delphi` calling `Python\ldap_auth.py`
  (ldap3 + NTLM bind). Credentials are never stored in ERAS.
- **Session management** uses UniGUI's per-session storage (`UniApplication.UniSession.Variables`).
  Sessions expire after `SessionTimeout` minutes of inactivity.
- **Audit logging** is written to `audit_logs` for every data mutation:
  workspace create/update/delete, snapshot create/freeze, ranking save, export.
- **Soft delete only** — workspaces are never physically deleted (`is_deleted = TRUE`).
- **Frozen snapshots** are enforced at the data module level (`DMSnapshot.IsSnapshotFrozen`);
  any attempt to save rankings against a frozen snapshot raises an exception.

---

## Snapshot Mode

All ranking work is performed against **snapshots** — point-in-time copies of Oracle ITS data
stored as JSON in `snapshot_applicants.applicant_data`.

1. Create a snapshot → ERAS pulls applicants from Oracle, stores JSON in MariaDB.
2. All ranking/scoring/export operations read from MariaDB only.
3. Freeze a snapshot to lock rankings for audit purposes.
4. Oracle ITS is **never written to or updated**.

---

## FastReport Template Customisation

Report templates (`.fr3` files) are stored in `ERAS\Reports\`:

| Template              | Purpose                         | Dataset band  |
|-----------------------|---------------------------------|---------------|
| `RankingList.fr3`     | Ranked applicant list (export)  | `Rankings`    |
| `ApplicantSummary.fr3`| Single applicant detail         | `ApplicantDetail` |
| `AuditLog.fr3`        | Audit trail report              | `AuditLog`    |

To customise: open the `.fr3` file in **FastReport Designer** (Tools → FR Designer in RAD Studio).
The `ReportsPath` config key controls where ERAS looks for templates at runtime.

---

## Python4Delphi Integration

- Python scripts are loaded from the directory specified by `PythonPath` in `config.ini`.
  **Paths are never hardcoded** in Delphi source.
- `TPythonEngine` is initialised in `TDMMain` at application startup.
- `TPythonDelphiVar` (`delphi_var`) is used to pass return values from Python back to Delphi.
- Scripts called at runtime:
  - `ldap_auth.py` — LDAP authentication on every login
- To add new Python functionality: add a `.py` file to `PythonPath`, call via
  `PythonEngine1.ExecString(...)` and read result from `PythonDelphiVar1.AsString`.

---

## Known Constraints

- **Windows only** — UniGUI runs as a Windows Service; Linux deployment is not supported.
- **Stateful sessions** — UniGUI maintains a server-side session per browser tab.
  Plan for concurrent user load accordingly (recommend ≤200 concurrent users per instance).
- **Single IIS site** — ERAS is exposed through IIS as a reverse-proxy to the UniGUI service.
- **Python 64-bit** — must match the Win64 Delphi target. Python4Delphi DLL path must be
  64-bit Python.
- **Oracle Instant Client** — required on the server if `OracleDirect = False`.
- **FastReport licence** — required on the build machine and the deployment server.
