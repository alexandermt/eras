from typing import Any
from app.database.oracle import oracle_cursor


def get_applicants(program: str = None, cycle_year: int = None) -> list[dict[str, Any]]:
    """
    Fetch applicants from Oracle ITS (read-only).
    Optional filters: program, cycle_year.
    """
    filters = []
    params: dict = {}

    if program:
        filters.append("a.program = :program")
        params["program"] = program

    if cycle_year:
        filters.append("a.cycle_year = :cycle_year")
        params["cycle_year"] = cycle_year

    where_clause = ("WHERE " + " AND ".join(filters)) if filters else ""

    sql = f"""
        SELECT
            a.applicant_id,
            a.first_name,
            a.last_name,
            a.email,
            a.program,
            a.cycle_year,
            a.status,
            a.gpa,
            a.usmle_step1,
            a.usmle_step2,
            a.date_of_birth,
            a.medical_school,
            a.graduation_year,
            a.research_experience,
            a.gender,
            a.home_state,
            a.publications,
            a.alpha_omega_alpha
        FROM eras_applicants a
        {where_clause}
        ORDER BY a.last_name, a.first_name
    """

    with oracle_cursor() as cursor:
        cursor.execute(sql, params)
        columns = [col[0].lower() for col in cursor.description]
        rows = cursor.fetchall()

    return [dict(zip(columns, row)) for row in rows]


def get_applicant(applicant_id: str) -> dict[str, Any] | None:
    """Fetch a single applicant by ID."""
    sql = """
        SELECT
            a.applicant_id,
            a.first_name,
            a.last_name,
            a.email,
            a.program,
            a.cycle_year,
            a.status,
            a.gpa,
            a.usmle_step1,
            a.usmle_step2,
            a.date_of_birth,
            a.medical_school,
            a.graduation_year,
            a.research_experience,
            a.personal_statement,
            a.away_rotations,
            a.gender,
            a.home_state,
            a.publications,
            a.alpha_omega_alpha
        FROM eras_applicants a
        WHERE a.applicant_id = :applicant_id
    """
    with oracle_cursor() as cursor:
        cursor.execute(sql, {"applicant_id": applicant_id})
        columns = [col[0].lower() for col in cursor.description]
        row = cursor.fetchone()

    if not row:
        return None
    return dict(zip(columns, row))
