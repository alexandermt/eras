from fastapi import APIRouter, Depends, HTTPException, status, Request
from sqlalchemy.orm import Session
from app.database.mariadb import get_db
from app.models.workspace import Workspace
from app.models.snapshot import Snapshot
from app.models.audit import AuditLog
from app.schemas.snapshot import SnapshotCreate, SnapshotOut, SnapshotDetail
from app.middleware.auth import get_current_user, require_role
from app.schemas.auth import TokenData
from app.services import oracle_service

router = APIRouter(prefix="/api/workspaces/{workspace_id}/snapshots", tags=["snapshots"])


def _get_workspace_or_404(workspace_id: int, db: Session) -> Workspace:
    ws = db.get(Workspace, workspace_id)
    if not ws:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Workspace not found")
    return ws


@router.get("/", response_model=list[SnapshotOut])
def list_snapshots(
    workspace_id: int,
    db: Session = Depends(get_db),
    current_user: TokenData = Depends(get_current_user),
):
    _get_workspace_or_404(workspace_id, db)
    return (
        db.query(Snapshot)
        .filter(Snapshot.workspace_id == workspace_id)
        .order_by(Snapshot.created_at.desc())
        .all()
    )


@router.post("/", response_model=SnapshotOut, status_code=status.HTTP_201_CREATED)
def create_snapshot(
    workspace_id: int,
    payload: SnapshotCreate,
    request: Request,
    db: Session = Depends(get_db),
    current_user: TokenData = Depends(require_role("admin", "selector")),
):
    """
    Create a snapshot by pulling current applicant data from Oracle ITS.
    Snapshot mode: applicant data is frozen at this point in time.
    """
    ws = _get_workspace_or_404(workspace_id, db)
    applicants = oracle_service.get_applicants(cycle_year=ws.cycle_year)

    snapshot = Snapshot(
        workspace_id=workspace_id,
        label=payload.label,
        description=payload.description,
        applicant_data=applicants,
        created_by=current_user.username,
    )
    db.add(snapshot)
    db.flush()
    db.add(AuditLog(
        username=current_user.username,
        action="create_snapshot",
        resource_type="snapshot",
        resource_id=str(snapshot.id),
        detail=f"workspace={workspace_id} label={payload.label}",
        ip_address=request.client.host if request.client else None,
    ))
    db.commit()
    db.refresh(snapshot)
    return snapshot


@router.get("/{snapshot_id}", response_model=SnapshotDetail)
def get_snapshot(
    workspace_id: int,
    snapshot_id: int,
    db: Session = Depends(get_db),
    current_user: TokenData = Depends(get_current_user),
):
    _get_workspace_or_404(workspace_id, db)
    snapshot = (
        db.query(Snapshot)
        .filter(Snapshot.id == snapshot_id, Snapshot.workspace_id == workspace_id)
        .first()
    )
    if not snapshot:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Snapshot not found")
    return snapshot


@router.delete("/{snapshot_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_snapshot(
    workspace_id: int,
    snapshot_id: int,
    request: Request,
    db: Session = Depends(get_db),
    current_user: TokenData = Depends(require_role("admin")),
):
    _get_workspace_or_404(workspace_id, db)
    snapshot = (
        db.query(Snapshot)
        .filter(Snapshot.id == snapshot_id, Snapshot.workspace_id == workspace_id)
        .first()
    )
    if not snapshot:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Snapshot not found")
    db.add(AuditLog(
        username=current_user.username,
        action="delete_snapshot",
        resource_type="snapshot",
        resource_id=str(snapshot_id),
        ip_address=request.client.host if request.client else None,
    ))
    db.delete(snapshot)
    db.commit()
