import cx_Oracle
import json

_conn = None


def init_connection(dsn: str, user: str, password: str):
    global _conn
    _conn = cx_Oracle.connect(user=user, password=password, dsn=dsn)


def get_applicants_page(cycle: int, programme: str,
                        limit: int = 100, offset: int = 0) -> str:
    """Read-only paginated applicant fetch. Returns JSON string."""
    cursor = _conn.cursor()
    cursor.execute("""
        SELECT a.applicant_id,
               a.forename,
               a.surname,
               a.email,
               a.dob,
               p.programme_code,
               p.application_status,
               p.submitted_date
        FROM   its_applicants a
        JOIN   its_programme_choices p ON p.applicant_id = a.applicant_id
        WHERE  p.cycle_year      = :cycle
          AND  p.programme_code  = :programme
        ORDER  BY a.surname, a.forename
        OFFSET :offset ROWS FETCH NEXT :limit ROWS ONLY
    """, cycle=cycle, programme=programme, limit=limit, offset=offset)
    cols = [d[0].lower() for d in cursor.description]
    rows = [dict(zip(cols, row)) for row in cursor.fetchall()]
    return json.dumps(rows, default=str)


def get_applicant_detail(applicant_id: str) -> str:
    """Full applicant detail. Returns JSON string."""
    cursor = _conn.cursor()
    cursor.execute("""
        SELECT a.*, p.*
        FROM   its_applicants a
        LEFT JOIN its_programme_choices p ON p.applicant_id = a.applicant_id
        WHERE  a.applicant_id = :applicant_id
    """, applicant_id=applicant_id)
    cols = [d[0].lower() for d in cursor.description]
    row = cursor.fetchone()
    if row:
        return json.dumps(dict(zip(cols, row)), default=str)
    return "{}"
