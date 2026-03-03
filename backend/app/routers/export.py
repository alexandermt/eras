from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.responses import Response
from sqlalchemy.orm import Session
from app.database.mariadb import get_db
from app.models.workspace import Workspace
from app.models.ranking import Ranking
from app.schemas.auth import TokenData
from app.middleware.auth import get_current_user
from app.services import oracle_service, export_service

router = APIRouter(prefix="/api/workspaces/{workspace_id}/export", tags=["export"])


@router.get("/ranked-list")
def export_ranked_list(
    workspace_id: int,
    db: Session = Depends(get_db),
    current_user: TokenData = Depends(get_current_user),
):
    """
    Generate and download a ranked applicant list as an Excel workbook.
    Applicant details are pulled from Oracle ITS and merged with stored rankings.
    """
    workspace = db.get(Workspace, workspace_id)
    if not workspace:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Workspace not found")

    rankings = (
        db.query(Ranking)
        .filter(Ranking.workspace_id == workspace_id)
        .order_by(Ranking.rank)
        .all()
    )

    if not rankings:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="No rankings found for this workspace",
        )

    # Fetch applicant details from Oracle and merge
    applicant_ids = [r.applicant_id for r in rankings]
    applicant_map = {
        a["applicant_id"]: a
        for a in oracle_service.get_applicants(cycle_year=workspace.cycle_year)
        if a["applicant_id"] in applicant_ids
    }

    rows = []
    for ranking in rankings:
        applicant = applicant_map.get(ranking.applicant_id, {})
        rows.append({
            **applicant,
            "rank": ranking.rank,
            "score": ranking.score,
            "notes": ranking.notes,
        })

    xlsx_bytes = export_service.build_ranked_export(
        workspace_name=workspace.name,
        cycle_year=workspace.cycle_year,
        ranked_applicants=rows,
    )

    filename = f"{workspace.name.replace(' ', '_')}_{workspace.cycle_year}_ranked_list.xlsx"
    return Response(
        content=xlsx_bytes,
        media_type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        headers={"Content-Disposition": f'attachment; filename="{filename}"'},
    )
