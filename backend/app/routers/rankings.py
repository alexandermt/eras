from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException, status, Request
from sqlalchemy.orm import Session
from app.database.mariadb import get_db
from app.models.workspace import Workspace
from app.models.ranking import Ranking
from app.models.audit import AuditLog
from app.schemas.ranking import RankingUpsert, RankingOut
from app.middleware.auth import get_current_user, require_role
from app.schemas.auth import TokenData

router = APIRouter(prefix="/api/workspaces/{workspace_id}/rankings", tags=["rankings"])


def _get_workspace_or_404(workspace_id: int, db: Session) -> Workspace:
    ws = db.get(Workspace, workspace_id)
    if not ws:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Workspace not found")
    return ws


@router.get("/", response_model=list[RankingOut])
def list_rankings(
    workspace_id: int,
    db: Session = Depends(get_db),
    current_user: TokenData = Depends(get_current_user),
):
    _get_workspace_or_404(workspace_id, db)
    return (
        db.query(Ranking)
        .filter(Ranking.workspace_id == workspace_id)
        .order_by(Ranking.rank)
        .all()
    )


@router.put("/", response_model=list[RankingOut])
def upsert_rankings(
    workspace_id: int,
    payload: list[RankingUpsert],
    request: Request,
    db: Session = Depends(get_db),
    current_user: TokenData = Depends(require_role("admin", "selector")),
):
    """
    Replace the full ranked list for a workspace.
    Accepts an ordered list; ranks are overwritten from the submitted payload.
    """
    _get_workspace_or_404(workspace_id, db)

    # Delete existing rankings for this workspace
    db.query(Ranking).filter(Ranking.workspace_id == workspace_id).delete()

    results = []
    for item in payload:
        ranking = Ranking(
            workspace_id=workspace_id,
            applicant_id=item.applicant_id,
            rank=item.rank,
            score=item.score,
            notes=item.notes,
            ranked_by=current_user.username,
        )
        db.add(ranking)
        results.append(ranking)

    db.flush()
    db.add(AuditLog(
        username=current_user.username,
        action="upsert_rankings",
        resource_type="ranking",
        resource_id=str(workspace_id),
        detail=f"{len(payload)} applicants ranked",
        ip_address=request.client.host if request.client else None,
    ))
    db.commit()
    for r in results:
        db.refresh(r)
    return results
