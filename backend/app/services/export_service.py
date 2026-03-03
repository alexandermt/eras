from io import BytesIO
from typing import Any
import openpyxl
from openpyxl.styles import Font, PatternFill, Alignment
from openpyxl.utils import get_column_letter


_HEADER_FILL = PatternFill("solid", fgColor="1F4E79")
_HEADER_FONT = Font(bold=True, color="FFFFFF")
_ALT_FILL = PatternFill("solid", fgColor="D6E4F0")


EXPORT_COLUMNS = [
    ("rank", "Rank"),
    ("applicant_id", "Applicant ID"),
    ("last_name", "Last Name"),
    ("first_name", "First Name"),
    ("email", "Email"),
    ("medical_school", "Medical School"),
    ("gpa", "GPA"),
    ("usmle_step1", "USMLE Step 1"),
    ("usmle_step2", "USMLE Step 2"),
    ("score", "Score"),
    ("notes", "Notes"),
]


def build_ranked_export(
    workspace_name: str,
    cycle_year: int,
    ranked_applicants: list[dict[str, Any]],
) -> bytes:
    """
    Build an Excel workbook with a ranked applicant list and return raw bytes.
    """
    wb = openpyxl.Workbook()
    ws = wb.active
    ws.title = f"{cycle_year} Ranked List"

    # Title row
    ws.merge_cells(f"A1:{get_column_letter(len(EXPORT_COLUMNS))}1")
    title_cell = ws["A1"]
    title_cell.value = f"{workspace_name} — {cycle_year} Ranked Applicant List"
    title_cell.font = Font(bold=True, size=14)
    title_cell.alignment = Alignment(horizontal="center")

    # Header row
    for col_idx, (_, header) in enumerate(EXPORT_COLUMNS, start=1):
        cell = ws.cell(row=2, column=col_idx, value=header)
        cell.fill = _HEADER_FILL
        cell.font = _HEADER_FONT
        cell.alignment = Alignment(horizontal="center")

    # Data rows
    for row_idx, applicant in enumerate(ranked_applicants, start=3):
        fill = _ALT_FILL if row_idx % 2 == 0 else PatternFill()
        for col_idx, (field, _) in enumerate(EXPORT_COLUMNS, start=1):
            cell = ws.cell(row=row_idx, column=col_idx, value=applicant.get(field))
            cell.fill = fill

    # Auto-fit columns
    for col_idx in range(1, len(EXPORT_COLUMNS) + 1):
        ws.column_dimensions[get_column_letter(col_idx)].auto_size = True

    buffer = BytesIO()
    wb.save(buffer)
    return buffer.getvalue()
